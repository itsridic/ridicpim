class SyncWithQBOWorker
  include Sidekiq::Worker

  def perform(current_account_id, amazon_statement_id)
    #CreateSalesReceiptWorker.perform_async(current_account_id, amazon_statement_id)
    receipt_id = SalesReceipt.last.id
    CreateExpenseReceiptWorker.perform_async(amazon_statement_id, current_account_id, receipt_id)
  end
end