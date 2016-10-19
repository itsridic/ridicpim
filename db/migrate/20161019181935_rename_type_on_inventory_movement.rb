class RenameTypeOnInventoryMovement < ActiveRecord::Migration[5.0]
  def change
    rename_column :inventory_movements, :type, :movement_type
  end
end
