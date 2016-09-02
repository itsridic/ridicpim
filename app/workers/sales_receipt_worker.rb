class SalesReceiptWorker
  include Sidekiq::Worker

  def perform(amazon_statement_id, current_account_id, receipt_id)
    puts "Creating Sales Receipt in QBO..."
    current_account = Account.find(current_account_id)
    receipt = SalesReceipt.find(receipt_id)

    qbo_rails = QboRails.new(QboConfig.last, :sales_receipt)
    qbo_receipt = qbo_rails.base.qr_model(:sales_receipt)
    qbo_receipt.customer_id = current_account.settings(:sales_receipt_default_customer).val
    qbo_receipt.txn_date = Date.parse(receipt.user_date.to_s)
    qbo_receipt.deposit_to_account_id = current_account.settings(:sales_receipt_deposit_to_account).val
    qbo_receipt.auto_doc_number!    
    qbo_rails = QboRails.new(QboConfig.last, :sales_receipt)
    receipt.sales.each do |sale|
      line_item = qbo_rails.base.qr_model(:line)
      line_item.amount = sale.amount.to_f
      line_item.description = sale.description
      line_item.sales_item! do |detail|
        unless sale.quantity * sale.rate == line_item.amount
          sale.amount = sale.quantity * sale.rate
          sale.save!
          line_item.amount = sale.quantity * sale.rate
        end
        detail.unit_price = sale.rate.to_f
        detail.quantity = sale.quantity
        if sale.product.present?
          detail.item_id = sale.product.qbo_id
        else
          detail.item_id = sale.qbo_id
        end
      end
      qbo_receipt.line_items << line_item
    end
    created_receipt = qbo_rails.create(qbo_receipt)
    puts "Calling CreateExpenseReceiptWorker..."
    CreateExpenseReceiptWorker.perform_async(amazon_statement_id, current_account_id)
    puts "CreateExpenseReceiptWorker Called!"
  end
end
