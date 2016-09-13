class SyncWithQBOWorker
  include Sidekiq::Worker

  def perform(current_account_id, amazon_statement_id)
    CreateSalesReceiptWorker.perform_async(current_account_id, amazon_statement_id)
  end
end