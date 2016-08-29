class AddQboIdToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :qbo_id, :integer
  end
end
