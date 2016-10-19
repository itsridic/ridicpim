class AddProductToTransfers < ActiveRecord::Migration[5.0]
  def change
    add_reference :transfers, :product, foreign_key: true
  end
end
