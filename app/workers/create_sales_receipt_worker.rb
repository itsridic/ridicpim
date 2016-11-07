class CreateSalesReceiptWorker
  include Sidekiq::Worker

  def perform(current_account_id, amazon_statement_id)
    amazon_statement = AmazonStatement.find(amazon_statement_id)
    receipt = AmazonSummary.new(eval(amazon_statement.summary)).create_sales_receipt(amazon_statement.period.split(" - ")[1], current_account_id)
    CreateItemsInQboWorker.perform_async(amazon_statement_id, current_account_id, receipt.id)
  end
end
