class CreateTransfers < ActiveRecord::Migration[5.0]
  def change
    create_table :transfers do |t|
      t.integer :from_location_id
      t.integer :to_location_id
      t.integer :quantity
      t.text :description

      t.timestamps
    end
  end
end
