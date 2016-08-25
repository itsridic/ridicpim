class CreateQboAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :qbo_accounts do |t|
      t.string :name
      t.string :account_type
      t.integer :qbo_id

      t.timestamps
    end
  end
end
