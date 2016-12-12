class QboAccount < ApplicationRecord
  scope :bank_account, -> { where(account_type: "Bank").or(where(account_type: "Credit Card")) }

  def self.create_account_from_response(result)
    QboAccount.create!(
      name: result.name,
      account_type: result.account_type,
      account_sub_type: result.account_sub_type,
      qbo_id: result.id
    )
  end
end
