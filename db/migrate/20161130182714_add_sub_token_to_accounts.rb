class AddSubTokenToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :sub_token, :string
  end
end
