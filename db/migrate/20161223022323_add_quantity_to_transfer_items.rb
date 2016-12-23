class AddQuantityToTransferItems < ActiveRecord::Migration[5.0]
  def change
    add_column :transfer_items, :quantity, :integer
  end
end
