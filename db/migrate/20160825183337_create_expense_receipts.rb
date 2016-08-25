class CreateExpenseReceipts < ActiveRecord::Migration[5.0]
  def change
    create_table :expense_receipts do |t|
      t.string :description
      t.references :qbo_account, foreign_key: true
      t.datetime :user_date

      t.timestamps
    end
  end
end
