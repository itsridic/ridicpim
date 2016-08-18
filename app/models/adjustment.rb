class Adjustment < ApplicationRecord
  belongs_to :adjustment_type
  belongs_to :product

  validates :product, presence: true
  validates :adjustment_type, presence: true
  validates :adjusted_quantity, presence: true
end
