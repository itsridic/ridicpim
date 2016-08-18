class CreateAdjustments < ActiveRecord::Migration[5.0]
  def change
    create_table :adjustments do |t|
      t.references :adjustment_type, foreign_key: true
      t.references :product, foreign_key: true
      t.integer :adjusted_quantity

      t.timestamps
    end
  end
end
