class CreateAmazonStatements < ActiveRecord::Migration[5.0]
  def change
    create_table :amazon_statements do |t|
      t.string :settlement_id
      t.string :period
      t.decimal :deposit_total
      t.json :summary

      t.timestamps
    end
  end
end
