class Sale < ApplicationRecord
  belongs_to :product
  belongs_to :sales_receipt
  before_save :create_inventory_movement
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

  def create_inventory_movement
    prod = self.product
    unless prod.nil?
      loc = self.sales_receipt.location
      qty = self.quantity * -1
      InventoryMovement.create!(location: loc, product: prod, quantity: qty, movement_type: "SALE")
    end
  end
end
