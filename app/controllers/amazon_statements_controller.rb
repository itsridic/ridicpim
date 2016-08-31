class AmazonStatementsController < ApplicationController
  before_action :set_qb_service, only: [:show]
  
  def index
    @amazon_statements = AmazonStatement.all.order("period DESC")
  end

  def show
    @amazon_statement = AmazonStatement.find(params[:id])
    redirect_to amazon_statements_path unless @amazon_statement.status == 'NOT_PROCESSED'
    ActiveRecord::Base.transaction do
      receipt = AmazonSummary.new(eval(@amazon_statement.summary)).create_sales_receipt(@amazon_statement.period.split(" - ")[1])
      # Create Sales Receipt in QBO.  ITW...
      # Set up QBO Rails
      qbo_rails = QboRails.new(QboConfig.last, :sales_receipt)
      qbo_receipt = qbo_rails.base.qr_model(:sales_receipt)
      qbo_receipt.customer_id = current_account.settings(:sales_receipt_default_customer).val
      qbo_receipt.txn_date = Date.parse(receipt.user_date.to_s)
      qbo_receipt.deposit_to_account_id = current_account.settings(:sales_receipt_deposit_to_account).val
      qbo_receipt.auto_doc_number!

      # Create Items in QBO If Necessary
      create_items_in_qbo(receipt)
      # Create Receipt in QBO
      create_sales_receipt_in_qbo(qbo_receipt, receipt)
      # Create Expense Receipt in QBO
      create_expense_receipt(@amazon_statement.period)
      # Create Journal Entries in QBO
      create_journal_entry(receipt, Date.parse(receipt.user_date.to_s))
    end
    redirect_to amazon_statements_path
  end

  def fetch
    client  = set_client
    begin
      reports = client.get_report_list(available_from_date: 91.days.ago.iso8601, report_type_list: "_GET_V2_SETTLEMENT_REPORT_DATA_XML_", max_count: 100) 
    rescue Excon::Errors::BadRequest => e
      puts "*" * 50
      logger.warn e.response.message
      puts "*" * 50
    end
    next_token = reports.next_token
    reports.xml["GetReportListResponse"]["GetReportListResult"]['ReportInfo'].each do |report|
      type = report['ReportType']
      if type.include?('_GET_V2_SETTLEMENT_REPORT_DATA_XML_')
        begin
          report_id = report['ReportId']
          puts report_id
          item_to_add = client.get_report(report_id).xml['AmazonEnvelope']['Message']['SettlementReport']
          add_statement_to_db(item_to_add, report_id)
        rescue => e
          p e
          next
        end
      else
        next
      end
    end

    while(next_token)
      begin
        reports    = client.get_report_list_by_next_token(next_token)
        next_token = reports.next_token
        reports.xml["GetReportListByNextTokenResponse"]["GetReportListByNextTokenResult"]["ReportInfo"].each do |report|
          type = report['ReportType']
          if type.include?('_GET_V2_SETTLEMENT_REPORT_DATA_XML_')
              report_id = report['ReportId']
              puts report_id
              item_to_add = client.get_report(report_id).xml['AmazonEnvelope']['Message']['SettlementReport']
              add_statement_to_db(item_to_add, report_id)
          else
            next
          end
          break if next_token == false
        end
        break if next_token == false
      rescue Excon::Errors::BadRequest => e
        puts "%" * 50
        logger.warn e.response.message
        puts "%" * 50
        next
      end
    end
    redirect_to amazon_statements_path
  end

  private

  def add_statement_to_db(item_to_add, report_id)
    if AmazonStatement.where(settlement_id: item_to_add['SettlementData']['AmazonSettlementID']).blank?
      period = item_to_add['SettlementData']['StartDate'].gsub(/T.+/, '') + ' - ' + item_to_add['SettlementData']['EndDate'].gsub(/T.+/, '')
      deposit_total = item_to_add['SettlementData']['TotalAmount']['__content__']
      status = 'NOT_PROCESSED'
      summary = item_to_add.to_s
      settlement_id = item_to_add['SettlementData']['AmazonSettlementID']
      AmazonStatement.create!(period: period, deposit_total: deposit_total, status: status, summary: summary, settlement_id: settlement_id, report_id: report_id)
    end
  end

  def set_qb_service
    @oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, QboConfig.first.token, QboConfig.first.secret)
  end

  def create_items_in_qbo(receipt)
    # Loop through and create items if necessary in QBO
    item_service = Quickbooks::Service::Item.new(:access_token => @oauth_client, :company_id => QboConfig.realm_id)
    qbo_rails = QboRails.new(QboConfig.last, :item)

    receipt.sales.each do |sale|
      if !sale.product.nil?
        if sale.product.qbo_id.nil?
          # Query QB to see if product exists.  If not, create it.
          items = item_service.query("SELECT * FROM Item WHERE sku = '#{sale.product.amazon_sku}'")
          p items
          if items.count == 0
            item = qbo_rails.base.qr_model(:item)
            item.income_account_id = current_account.settings(:sales_receipt_income_account).val
            item.type = "NonInventory"
            item.name = sale.product.amazon_sku
            item.description = sale.product.name
            item.unit_price = sale.product.price
            item.sku = sale.product.amazon_sku
          else
            sale.product.qbo_id = items.entries[0].id
            sale.product.save
          end
          begin
            created_item = qbo_rails.create(item)
            sale.product.qbo_id = created_item.id
            sale.product.save
          rescue Exception => e
            puts "**************** QBO ERROR 1 *******************"
            p e
            puts "**************** QBO ERROR 1 *******************"
          end
        end
      else
        prod = sale.description.gsub(" ", "_").camelize
        income_account_id = classify_income_account(prod)
        items = item_service.query("SELECT * FROM Item WHERE name = '#{prod}'")
        if items.entries.count == 0
          # Create Item in QBO
          item = qbo_rails.base.qr_model(:item)
          item.income_account_id = income_account_id
          item.type = "NonInventory"
          item.name = prod
          item.description = prod
          item.unit_price = sale.rate
          begin
            created_item = qbo_rails.create(:item)
          rescue Exception => e
            puts "**************** QBO ERROR 2 *******************"
            p e
            puts "**************** QBO ERROR 2 *******************"
          end
        else
          sale.qbo_id = items.entries[0].id
          sale.save!
        end
      end
    end
  end

  def classify_income_account(prod)
    if prod == 'Shipping'
      # Use "Shipping Income" account
      current_account.settings(:classify_shipping).val
    elsif prod == 'SaleTax'
      # Use "Sale Tax Payable" account
      current_account.settings(:classify_sale_tax).val
    elsif prod == 'PromotionShipping'
      # Use "Promo Rebates on Shipping" account
      current_account.settings(:classify_promotion_shipping).val
    elsif prod == 'ShippingSalesTax'
      # Use Sale Tax Payable:FBAShippingTax" account
      current_account.settings(:classify_shipping_sales_tax).val
    elsif prod == 'FBAgiftwrap'
      # Use "Services" account
      current_account.settings(:classify_fba_gift_wrap).val
    elsif prod == 'BalanceAdjustment'
      # Use "Gross Receipts" account
      current_account.settings(:classify_balance_adjustment).val
    elsif prod == 'GiftWrapTax'
      current_account.settings(:classify_gift_wrap_tax).val
    else
      # Use "Service" account
      current_account.settings(:classify_unknown).val
    end
  end

  def create_sales_receipt_in_qbo(qbo_receipt, receipt)
    qbo_rails = QboRails.new(QboConfig.last, :sales_receipt)
    receipt.sales.each do |sale|
      line_item = qbo_rails.base.qr_model(:line)
      line_item.amount = sale.amount.to_f
      line_item.description = sale.description
      line_item.sales_item! do |detail|
        unless sale.quantity * sale.rate == line_item.amount
          sale.amount = sale.quantity * sale.rate
          sale.save!
          line_item.amount = sale.quantity * sale.rate
        end
        detail.unit_price = sale.rate.to_f
        detail.quantity = sale.quantity
        if sale.product.present?
          detail.item_id = sale.product.qbo_id
        else
          detail.item_id = sale.qbo_id
        end
      end
      qbo_receipt.line_items << line_item
    end
    created_receipt = qbo_rails.create(qbo_receipt)    
  end

 def create_expense_receipt(desc)
    # Create Expense Receipt in App
    expense_receipt = AmazonSummary.new(eval(@amazon_statement.summary)).create_expense_receipt(desc, current_account.settings(:expense_bank_account).val)
    # Create Expense Receipt in QBO
    qbo_rails = QboRails.new(QboConfig.last, :purchase)
    purchase = qbo_rails.base.qr_model(:purchase)
    purchase.txn_date = @amazon_statement.period.split(" - ")[1]
    purchase.payment_type = 'Cash'
    purchase.account_id = current_account.settings(:expense_bank_account).val
    purchase.line_items = []
    # Loop through all expenses and create new model for it.
    expense_receipt.expenses.each do |expense|
      line_item = qbo_rails.base.qr_model(:purchase_line_item)
      line_item.amount = expense.amount
      line_item.description = expense.description
      line_item.account_based_expense! do |detail|
        detail.account_id = expense.qbo_account.qbo_id
        detail.customer_id = current_account.settings(:expense_customer).val
      end
      purchase.line_items << line_item
    end
    result = qbo_rails.create(purchase)
  end

  def create_journal_entry(receipt, txn_date)
    puts "CREATING JOURNAL ENTRY"
    p "$" * 25
    p "Creating Journal Entry"
    p "$" * 25
    # Lookup / Create Accounts in QBO
    # STEP 1: FIND "Inventory Asset" ACCOUNT
    account_service = Quickbooks::Service::Account.new(:access_token => @oauth_client, :company_id => QboConfig.realm_id)
    qbo_rails = QboRails.new(QboConfig.last, :account)
    accounts = account_service.query("SELECT * FROM Account WHERE name = 'Inventory Asset'")
    inventory_asset_account_id = accounts.entries[0].id.to_i
    puts "*" * 25
    puts "Account: #{accounts}"
    puts "inventory_asset_account_id = #{inventory_asset_account_id}"
    puts "*" * 25
    # STEP 2: Lookup / Create SubAccounts for Items (if they do not exist):
    Product.all.each do |prod|
      # Check to see if id is already stored in DB
      if prod.inventory_asset_account_id.nil?
        account = account_service.query("SELECT * FROM Account WHERE name = 'Inventory - #{prod.amazon_sku}'")
        p account
        if account.entries.count == 0
          puts "THIS ACCOUNT DOES NOT EXIST.  CREATING IN QBO..."
          new_account = qbo_rails.base.qr_model(:account)
          new_account.name = "Inventory - #{prod.amazon_sku}"
          new_account.classification = "Asset"
          new_account.parent_id = inventory_asset_account_id
          new_account.account_type = "Other Current Asset"
          new_account.account_sub_type = "Inventory"
          result = qbo_rails.create(new_account)
          p result
          prod.inventory_asset_account_id = result.id
          prod.save
        else
          # ID not in DB, but exists in QBO
          puts "ID does not exist in DB, but does in QBO. Adding to DB..."
          puts ">>>>>>inventory_asset_account_id = #{accounts.entries[0].id}"
          prod.inventory_asset_account_id = account.entries[0].id.to_i
          prod.save
        end
      end
    end
    # STEP 3: Create Journal Entry
    qbo_rails = QboRails.new(QboConfig.last, :journal_entry)
    journal_entry = qbo_rails.base.qr_model(:journal_entry)
    journal_entry.txn_date = txn_date
    receipt.sales.each do |sale|
      if sale.product and sale.quantity > 0
        # Create Credit Line
        average_cost = sale.product.average_cost(receipt.user_date)
        description = "Sale of #{sale.quantity} at #{average_cost} (#{sale.product.amazon_sku})"
        line_item_credit = qbo_rails.base.qr_model(:line)
        line_item_credit.description = description
        line_item_credit.amount      = average_cost * sale.quantity
        line_item_credit.detail_type = 'JournalEntryLineDetail'
        jel = qbo_rails.base.qr_model(:journal_entry_line_detail)
        jel.posting_type = 'Credit'
        jel.account_id = sale.product.inventory_asset_account_id
        line_item_credit.journal_entry_line_detail = jel
        journal_entry.line_items << line_item_credit

        # Create Debit Line
        line_item_debit = qbo_rails.base.qr_model(:line)
        average_cost = sale.product.average_cost(receipt.user_date)
        description = "Sale of #{sale.quantity} at #{average_cost} (#{sale.product.amazon_sku})"
        line_item_debit.description = description
        line_item_debit.amount      = average_cost * sale.quantity
        line_item_debit.detail_type = 'JournalEntryLineDetail'
        jel = qbo_rails.base.qr_model(:journal_entry_line_detail)
        jel.posting_type = 'Debit'
        jel.account_id = 80 # TO DO: Set up question! 80 = Sandbox2
        line_item_debit.journal_entry_line_detail = jel
        journal_entry.line_items << line_item_debit
      end
    end
    result = qbo_rails.create(journal_entry)
    p result
  end  
end
