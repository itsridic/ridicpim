class CreateSalesReceipts < ActiveRecord::Migration[5.0]
  def change
    create_table :sales_receipts do |t|
      t.references :contact, foreign_key: true
      t.references :payment, foreign_key: true
      t.datetime :user_date

      t.timestamps
    end
  end
end
