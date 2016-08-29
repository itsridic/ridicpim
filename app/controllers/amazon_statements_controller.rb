class AmazonStatementsController < ApplicationController
  before_action :set_qb_service, only: [:show]
  
  def index
    @amazon_statements = AmazonStatement.all.order("period DESC")
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
      create_items_in_qbo(receipt, qbo_rails, qbo_receipt)
      fail
    end
    redirect_to amazon_statements_path
  end

  private

  def set_client
    MWS::Reports::Client.new(
      primary_marketplace_id: Credential.last.primary_marketplace_id,
      merchant_id: Credential.last.merchant_id,
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      auth_token: Credential.last.auth_token
    )
  end

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
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, QboConfig.first.token, QboConfig.first.secret)
    @vendor_service = Quickbooks::Service::Vendor.new
    @vendor_service.access_token = oauth_client
    @vendor_service.company_id = QboConfig.realm_id
  end

  def create_items_in_qbo(receipt, qbo_rails, qbo_receipt)
    # Loop through and create items if necessary in QBO
    receipt.sales.each do |sale|
      if !sale.product.nil?
        if sale.product.qbo_id.nil?
          # Query QB to see if product exists.  If not, create it.
          items = item_service.query("SELECT * FROM Item WHERE sku = '#{sale.product.amazon_sku}'")
          p items
          if items.count == 0
            item = Quickbooks::Model::Item.new
            item.income_account_id = Config.sales_receipt_income_account
            item.type = "NonInventory"
            item.name = sale.product.amazon_sku
            item.description = sale.product.name
            item.unit_price = sale.product.price
            item.sku = sale.product.amazon_sku
            p item
          else
            sale.product.qbo_id = items.entries[0].id
            sale.product.save
          end
          begin
            created_item = item_service.create(item)
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
          item = Quickbooks::Model::Item.new
          item.income_account_id = income_account_id
          item.type = "NonInventory"
          item.name = prod
          item.description = prod
          item.unit_price = sale.rate
          begin
            created_item = item_service.create(item)
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
end
