class AddInventoryAssetAccountIdToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :inventory_asset_account_id, :integer
  end
end
