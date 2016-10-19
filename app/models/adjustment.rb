class Adjustment < ApplicationRecord
  belongs_to :adjustment_type
  belongs_to :product
  belongs_to :location
  after_save :set_user_date

  validates :product, presence: true
  validates :adjustment_type, presence: true
  validates :adjusted_quantity, presence: true
  validates :location, presence: true

  private

  def set_user_date
    if user_date.blank?
      self.update_column(:user_date, self.created_at)
    end    
  end
end
