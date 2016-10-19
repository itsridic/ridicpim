class AddLocationToSalesReceipt < ActiveRecord::Migration[5.0]
  def change
    add_reference :sales_receipts, :location, foreign_key: true
  end
end
