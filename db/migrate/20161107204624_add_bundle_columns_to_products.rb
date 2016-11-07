class AddBundleColumnsToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :bundle_quantity, :integer, default: 1
    add_reference :products, :bundle_product, references: :products, index: true
  end
end
