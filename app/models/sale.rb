class Sale < ApplicationRecord
  belongs_to :product
  belongs_to :sales_receipt
  after_save :set_rate

  validates :quantity, presence: true
  validates :amount, presence: true

  default_scope { order(:id) }
  
  private

  def set_rate
    if self.rate.blank?
      self.update_column(:rate, amount.to_f / quantity.to_f)
    end
  end  
end
