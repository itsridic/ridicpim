class CreateExpenseReceiptWorker
  include Sidekiq::Worker

  def perform(amazon_statement_id, current_account_id)
    puts "Creating Expense Receipt..."
    amazon_statement = AmazonStatement.find(amazon_statement_id)
    current_account = Account.find(current_account_id)

    expense_receipt = AmazonSummary.new(eval(amazon_statement.summary)).create_expense_receipt(amazon_statement.period, 
                                                                          current_account.settings(:expense_bank_account).val)
    CreateExpenseReceiptInQBOWorker.perform_async(amazon_statement_id, current_account_id, expense_receipt.id)
  end
end
