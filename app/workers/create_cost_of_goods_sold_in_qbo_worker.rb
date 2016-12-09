class CreateCostOfGoodsSoldInQboWorker
  include Sidekiq::Worker

  def perform(amazon_statement_id, receipt_id, current_account_id)
    @current_account = Account.find(current_account_id)
    @amazon_statement = AmazonStatement.find(amazon_statement_id)
    @receipt = SalesReceipt.find(receipt_id)
    @txn_date = Date.parse(@receipt.user_date.to_s)
    @qbo_rails = QboRails.new(QboConfig.last, :journal_entry)
    @journal_entry = @qbo_rails.base.qr_model(:journal_entry)
    @journal_entry.txn_date = @txn_date
    @discount_item = Product.find_by(qbo_id: @current_account.settings(:discount_item).val)
    create_cost_of_goods_sold
  end

  def create_cost_of_goods_sold
    @receipt.sales.each do |sale|
      next if sale.product == @discount_item
      if sale.product and sale.quantity != 0
        sale_or_refund = sale.quantity < 0 ? "refund" : "sale"
        create_journal_line_entry("Credit", sale, sale_or_refund)
        create_journal_line_entry("Debit", sale, sale_or_refund)
      end
    end
    result = @qbo_rails.create(@journal_entry)
    @amazon_statement.status = "COMPLETE"
    @amazon_statement.save
  end

  def create_journal_line_entry(type, sale, sale_or_refund)
    qb_rails = QboRails.new(QboConfig.last, :journal_entry)
    average_cost = sale.product.average_cost(@receipt.user_date)
    description = "#{sale_or_refund} of #{sale.quantity} at #{average_cost} (#{sale.product.amazon_sku})"
    line_item = qb_rails.base.qr_model(:line)
    line_item.description = description
    line_item.amount      = (average_cost * sale.quantity).abs
    line_item.detail_type = 'JournalEntryLineDetail'
    jel = qb_rails.base.qr_model(:journal_entry_line_detail)
    jel.posting_type = type
    jel.account_id = categorize_account(type, sale_or_refund, sale)
    line_item.journal_entry_line_detail = jel
    @journal_entry.line_items << line_item
  end

  def categorize_account(type, sale_or_refund, sale)
    match = (type + "-" + sale_or_refund).downcase
    if match == "credit-sale" or match == "debit-refund"
      return sale.product.inventory_asset_account_id
    elsif match == "credit-refund" or match == "debit-sale"
      return @current_account.settings(:cost_of_goods_sold_account).val
    end
  end
end
