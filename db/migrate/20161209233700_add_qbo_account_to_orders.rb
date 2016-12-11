class AddQboAccountToOrders < ActiveRecord::Migration[5.0]
  def change
    add_reference :orders, :qbo_account, foreign_key: true
  end
end
