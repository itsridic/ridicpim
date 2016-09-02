class CreateExpenseReceiptInQBOWorker
  include Sidekiq::Worker

  def perform(amazon_statement_id, current_account_id, expense_receipt_id, receipt_id)
    amazon_statement = AmazonStatement.find(amazon_statement_id)
    current_account = Account.find(current_account_id)
    expense_receipt = ExpenseReceipt.find(expense_receipt_id)

    qbo_rails = QboRails.new(QboConfig.last, :purchase)
    purchase = qbo_rails.base.qr_model(:purchase)
    purchase.txn_date = amazon_statement.period.split(" - ")[1]
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
    CreateCostOfGoodsSoldInQboWorker.perform_async(amazon_statement_id, receipt_id)
  end
end
