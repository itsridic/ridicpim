class CreateSales < ActiveRecord::Migration[5.0]
  def change
    create_table :sales do |t|
      t.references :sales_receipt, foreign_key: true
      t.references :product, foreign_key: true
      t.integer :quantity
      t.decimal :amount
      t.decimal :rate
      t.string :description
      t.integer :qbo_id

      t.timestamps
    end
  end
end
