class AddReferenceIdToInventoryMovements < ActiveRecord::Migration[5.0]
  def change
    add_column :inventory_movements, :reference_id, :integer
  end
end
