class AddUserDateToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :user_date, :datetime
  end
end
