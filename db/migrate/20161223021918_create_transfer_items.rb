class CreateTransferItems < ActiveRecord::Migration[5.0]
  def change
    create_table :transfer_items do |t|
      t.references :transfer, foreign_key: true
      t.references :product, foreign_key: true
      t.integer :from_location
      t.integer :to_location
      t.text :description

      t.timestamps
    end
  end
end
