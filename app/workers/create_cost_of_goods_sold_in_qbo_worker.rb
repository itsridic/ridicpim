class CreateCostOfGoodsSoldInQboWorker
  include Sidekiq::Worker

  def perform(amazon_statement_id, receipt_id, current_account_id)
    current_account = Account.find(current_account_id)    
    amazon_statement = AmazonStatement.find(amazon_statement_id)
    receipt = SalesReceipt.find(receipt_id)
    txn_date = Date.parse(receipt.user_date.to_s)
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, QboConfig.first.token, QboConfig.first.secret)

    discount_item = Product.find_by(qbo_id: current_account.settings(:discount_item).val)
    # Lookup / Create Accounts in QBO
    # STEP 1: FIND "Inventory Asset" ACCOUNT
    account_service = Quickbooks::Service::Account.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)
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
      next if sale.product == discount_item
      if sale.product and sale.quantity != 0
        sale_or_refund = ""
        if sale.quantity > 0
          sale_or_refund = "Sale"
        elsif sale.quantity < 0
          sale_or_refund = "Refund"
        end
        # Create Credit Line
        average_cost = sale.product.average_cost(receipt.user_date)
        description = "#{sale_or_refund} of #{sale.quantity} at #{average_cost} (#{sale.product.amazon_sku})"
        line_item_credit = qbo_rails.base.qr_model(:line)
        line_item_credit.description = description
        line_item_credit.amount      = (average_cost * sale.quantity).abs
        line_item_credit.detail_type = 'JournalEntryLineDetail'
        jel = qbo_rails.base.qr_model(:journal_entry_line_detail)
        jel.posting_type = 'Credit'
        jel.account_id = sale.product.inventory_asset_account_id
        line_item_credit.journal_entry_line_detail = jel
        journal_entry.line_items << line_item_credit

        # Create Debit Line
        line_item_debit = qbo_rails.base.qr_model(:line)
        average_cost = sale.product.average_cost(receipt.user_date)
        description = "#{sale_or_refund} of #{sale.quantity} at #{average_cost} (#{sale.product.amazon_sku})"
        line_item_debit.description = description
        line_item_debit.amount      = (average_cost * sale.quantity).abs
        line_item_debit.detail_type = 'JournalEntryLineDetail'
        jel = qbo_rails.base.qr_model(:journal_entry_line_detail)
        jel.posting_type = 'Debit'
        jel.account_id = current_account.settings(:cost_of_goods_sold_account).val
        line_item_debit.journal_entry_line_detail = jel
        journal_entry.line_items << line_item_debit
      end
    end
    result = qbo_rails.create(journal_entry)
    amazon_statement.status = "COMPLETE"
    amazon_statement.save
  end
end
