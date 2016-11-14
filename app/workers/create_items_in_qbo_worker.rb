class CreateItemsInQboWorker
  include Sidekiq::Worker

  def perform(amazon_statement_id, current_account_id, receipt_id)
    puts "Creating Items in QBO..."
    @current_account = Account.find(current_account_id)
    receipt = SalesReceipt.find(receipt_id)
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, QboConfig.first.token, QboConfig.first.secret)

    item_service = Quickbooks::Service::Item.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)
    qbo_rails = QboRails.new(QboConfig.last, :item)

    receipt.sales.each do |sale|
      if !sale.product.nil?
        if sale.product.qbo_id.nil?
          # Query QB to see if product exists.  If not, create it.
          items = item_service.query("SELECT * FROM Item WHERE sku = '#{sale.product.amazon_sku}'")
          p items
          if items.count == 0
            item = qbo_rails.base.qr_model(:item)
            item.income_account_id = @current_account.settings(:sales_receipt_income_account).val
            item.type = "NonInventory"
            item.name = sale.product.amazon_sku
            item.description = sale.product.name
            item.unit_price = sale.product.price
            item.sku = sale.product.amazon_sku
          else
            sale.product.qbo_id = items.entries[0].id
            sale.product.save
          end
          begin
            created_item = qbo_rails.create(item)
            sale.product.qbo_id = created_item.id
            sale.product.save
          rescue Exception => e
            puts "**************** QBO ERROR 1 *******************"
            p e
            puts "**************** QBO ERROR 1 *******************"
          end
        end
      else
        prod = sale.description.gsub(" ", "_").camelize
        income_account_id = classify_income_account(prod)
        items = item_service.query("SELECT * FROM Item WHERE name = '#{prod}'")
        if items.entries.count == 0
          # Create Item in QBO
          item = qbo_rails.base.qr_model(:item)
          item.income_account_id = income_account_id
          item.type = "NonInventory"
          item.name = prod
          item.description = prod
          item.unit_price = sale.rate
          begin
            created_item = qbo_rails.create(item)
            p created_item
            sale.qbo_id = created_item.id
            sale.save
          rescue Exception => e
            puts "**************** QBO ERROR 2 *******************"
            p e
            puts "**************** QBO ERROR 2 *******************"
          end
        else
          sale.qbo_id = items.entries[0].id
          sale.save!
        end
      end
    end
    SalesReceiptWorker.perform_async(amazon_statement_id, current_account_id, receipt_id)
  end

  def classify_income_account(prod)
    if prod == 'Shipping'
      @current_account.settings(:classify_shipping).val
    elsif prod == 'SalesTax'
      @current_account.settings(:classify_sale_tax).val
    elsif prod == 'PromotionShipping'
      @current_account.settings(:classify_promotion_shipping).val
    elsif prod == 'ShippingSalesTax'
      @current_account.settings(:classify_shipping_sales_tax).val
    elsif prod == 'FBAgiftwrap'
      @current_account.settings(:classify_fba_gift_wrap).val
    elsif prod == 'BalanceAdjustment'
      @current_account.settings(:classify_balance_adjustment).val
    elsif prod == 'GiftWrapTax'
      @current_account.settings(:classify_gift_wrap_tax).val
    else
      @current_account.settings(:classify_unknown).val
    end
  end  
end
