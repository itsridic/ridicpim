class ExpenseReceipt < ApplicationRecord
  belongs_to :qbo_account
  has_many :expenses, dependent: :destroy
  accepts_nested_attributes_for :expenses, reject_if: :all_blank, allow_destroy: true
  after_save :set_user_date

  private

  def set_user_date
    if user_date.blank?
      self.update_column(:user_date, self.created_at)
    end
  end  
end
