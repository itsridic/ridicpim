class CreateExpenseReceipt
  def self.in_app_from_order(current_account, qbo_service_account, order)
    expense_receipt = build_expense_receipt(order)

    order.order_items.each do |item|
      product = Product.create_inventory_asset_account(current_account, qbo_service_account, item.product)
      expense = create_expense_line(order, item, product)
      expense_receipt.expenses << expense
    end
    expense_receipt.save
    expense_receipt
  end

  def self.in_qbo(expense_receipt, qbo_account_id)
    qbo_rails = QboRails.new(QboConfig.last, :purchase)
    purchase = qbo_rails.base.qr_model(:purchase)
    purchase.txn_date = expense_receipt.user_date
    purchase.payment_type = 'Cash'
    purchase.account_id = QboAccount.find_by(id: qbo_account_id).qbo_id
    purchase.line_items = []
    # Loop through all expenses and create new model for it.
    expense_receipt.expenses.each do |expense|
      line_item = qbo_rails.base.qr_model(:purchase_line_item)
      line_item.amount = expense.amount
      line_item.description = expense.description
      line_item.account_based_expense! do |detail|
        detail.account_id = expense.qbo_account.qbo_id
      end
      purchase.line_items << line_item
    end
    result = qbo_rails.create(purchase)
  end

  def self.build_expense_receipt(order)
    ExpenseReceipt.new(description: "Expense for '#{order.name}'",
                       qbo_account_id: order.qbo_account_id,
                       user_date: order.user_date)
  end

  def self.create_expense_line(order, item, product)
    expense = Expense.new(
      qbo_account: QboAccount.find_by(qbo_id: product.inventory_asset_account_id),
      description: order.name,
      amount: item.cost
    )
    p "$$" * 50
    p expense
    expense
  end
end
