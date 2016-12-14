class AmazonStatementsController < ApplicationController
  def index
    load_statements
  end

  def show
    load_statement
    statement_status('PROCESSING...')
    process_into_qbo
  end

  def fetch
    @client = set_client
    reports = reports_list_from_amazon
    next_token = reports.next_token
    process_reports(reports)
    process_reports_by_next_token(next_token)
    redirect_to amazon_statements_path
  end

  private

  def add_statement_to_db(item_to_add, report_id)
    if AmazonStatement.settlement_exists(
      item_to_add['SettlementData']['AmazonSettlementID']
    ).blank?
      period = amazon_period(item_to_add)
      deposit_total = amazon_deposit_total(item_to_add)
      status = 'NOT_PROCESSED'
      summary = item_to_add.to_s
      settlement_id = item_to_add['SettlementData']['AmazonSettlementID']
      AmazonStatement.create!(
        period: period, deposit_total: deposit_total, status: status,
        summary: summary, settlement_id: settlement_id, report_id: report_id
      )
    end
  end

  def load_statements
    @amazon_statements ||= statement_scope
  end

  def load_statement
    @amazon_statement ||= statement_scope.find(params[:id])
  end

  def statement_status(status)
    @amazon_statement.status = status
    @amazon_statement.save
  end

  def process_into_qbo
    SyncWithQBOWorker.perform_async(current_account.id, @amazon_statement.id)
    redirect_to amazon_statements_path
  end

  def statement_scope
    AmazonStatement.all
  end

  def reports_list_from_amazon
    @client.get_report_list(
      available_from_date: 91.days.ago.iso8601,
      report_type_list: '_GET_V2_SETTLEMENT_REPORT_DATA_XML_',
      max_count: 100
    )
  rescue Excon::Errors::BadRequest => e
    logger.warn e.response.message
  end

  def amazon_period(item_to_add)
    item_to_add['SettlementData']['StartDate'].gsub(/T.+/, '') + ' - ' +
      item_to_add['SettlementData']['EndDate'].gsub(/T.+/, '')
  end

  def amazon_deposit_total(item_to_add)
    item_to_add['SettlementData']['TotalAmount']['__content__']
  end

  def process_report(report)
    report_id = report['ReportId']
    puts report_id
    item_to_add = @client.get_report(report_id)
                        .xml['AmazonEnvelope']['Message']['SettlementReport']
    add_statement_to_db(item_to_add, report_id)
  rescue => e
    p e
  end

  def process_reports(reports)
    reports.xml['GetReportListResponse']['GetReportListResult']['ReportInfo']
           .each do |report|
      process_report(report)
    end
  end

  def process_reports_by_next_token(next_token)
    while next_token
      begin
        reports    = @client.get_report_list_by_next_token(next_token)
        next_token = reports.next_token
        reports.xml['GetReportListByNextTokenResponse']
        ['GetReportListByNextTokenResult']['ReportInfo'].each do |report|
          process_report(report)
          break if next_token == false
        end
        break if next_token == false
      rescue Excon::Errors::BadRequest => e
        logger.warn e.response.message
        next
      end
    end
  end
end
