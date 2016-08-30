class AddAccountSubTypeToQboAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :qbo_accounts, :account_sub_type, :string
  end
end
