class AddQboIdAndSourceToSalesReceipts < ActiveRecord::Migration[5.0]
  def change
    add_column :sales_receipts, :source, :string
    add_column :sales_receipts, :qbo_id, :integer
  end
end
