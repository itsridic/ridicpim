class AddUserDateToAdjustments < ActiveRecord::Migration[5.0]
  def change
    add_column :adjustments, :user_date, :datetime
  end
end
