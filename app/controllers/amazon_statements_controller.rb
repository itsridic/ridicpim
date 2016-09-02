class AmazonStatementsController < ApplicationController
  before_action :set_qb_service, only: [:show]
  
  def index
    @amazon_statements = AmazonStatement.all.order("period DESC")
  end

  def show
    @amazon_statement = AmazonStatement.find(params[:id])
    @amazon_statement.status = "PROCESSING..."
    @amazon_statement.save
    #redirect_to amazon_statements_path unless @amazon_statement.status == 'NOT_PROCESSED'
    ActiveRecord::Base.transaction do
      # @amazon_statement.status = "PROCESSING..."
      # @amazon_statement.save
      SyncWithQBOWorker.perform_async(current_account.id, @amazon_statement.id)
      #create_expense_receipt(@amazon_statement.period)
      # Create Journal Entries in QBO
      #create_journal_entry(receipt, Date.parse(receipt.user_date.to_s))
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
end
