class CreateInventoryAssetInQboWorker
  include Sidekiq::Worker

  def perform(amazon_statement_id, receipt_id, current_account_id)
    unless Product.needs_inventory_asset.count.zero?
      account_service = QuickbooksServiceFactory.new.account_service
      current_account = Account.find(current_account_id)
      inventory_asset_account_id = current_account.settings(:inventory_asset).val
      Product.needs_inventory_asset.each do |prod|
        account = account_service.query("SELECT * FROM Account WHERE name = 'Inventory - #{prod.amazon_sku}'")
        if account.entries == 0
          create_account_in_qbo(prod, inventory_asset_account_id)
        end
      end
    end
    CreateCostOfGoodsSoldInQboWorker.perform_async(amazon_statement_id, receipt_id, current_account_id)
  end

  def create_account_in_qbo(product, inventory_asset_account_id)
    @qbo_rails ||= QboRails.new(QboConfig.last, :account)
    new_account = qbo_rails.base.qr_model(:account)
    new_account.name = "Inventory - #{prod.amazon_sku}"
    new_account.classification = "Asset"
    new_account.parent_id = inventory_asset_account_id
    new_account.account_type = "Other Current Asset"
    new_account.account_sub_type = "Inventory"
    result = qbo_rails.create(new_account)
    product.inventory_asset_account_id = result.id
    product.save
  end
end
