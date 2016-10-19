class CreateInventoryMovements < ActiveRecord::Migration[5.0]
  def change
    create_table :inventory_movements do |t|
      t.references :location, foreign_key: true
      t.references :product, foreign_key: true
      t.integer :quantity
      t.string :type

      t.timestamps
    end
  end
end
