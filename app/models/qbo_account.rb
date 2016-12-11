class QboAccount < ApplicationRecord
  scope :bank_account, -> { where(account_type: "Bank").or(where(account_type: "Credit Card")) }
end
