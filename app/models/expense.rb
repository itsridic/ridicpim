class Expense < ApplicationRecord
  belongs_to :expense_receipt
  belongs_to :qbo_account
end
