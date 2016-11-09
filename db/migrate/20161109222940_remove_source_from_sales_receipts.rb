class RemoveSourceFromSalesReceipts < ActiveRecord::Migration[5.0]
  def change
    remove_column :sales_receipts, :source, :string
  end
end
