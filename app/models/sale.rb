class Sale < ApplicationRecord
  belongs_to :product
  belongs_to :sales_receipt
  after_save :set_rate, :create_inventory_movement
  after_destroy :remove_inventory_movement

  validates :quantity, presence: true
  validates :amount, presence: true

  validates :product, presence: true, allow_blank: true
  validates :description, presence: true, allow_blank: true


  validate :product_or_description

  default_scope { order(:id) }
  
  private

  def product_or_description
    unless product.blank? or description.blank?
      errors.add(:line, "must specify a product or description, not both")
    end
  end

  def set_rate
    if self.rate.blank?
      self.update_column(:rate, amount.to_f / quantity.to_f)
    end
  end

  def create_inventory_movement
    inventory_movement = InventoryMovement.find_by(movement_type: "SALE", reference_id: self.id)
    if inventory_movement
      prod = self.product
      unless prod.nil?
        loc = self.sales_receipt.location
        qty = self.quantity * -1
        inventory_movement.update(location: loc, product: prod, quantity: qty, movement_type: "SALE")
      end
    else
      prod = self.product
      unless prod.nil?
        loc = self.sales_receipt.location
        qty = self.quantity * -1
        InventoryMovement.create!(location: loc, product: prod, quantity: qty, movement_type: "SALE", reference_id: self.id)
      end      
    end
  end

  def remove_inventory_movement
    inventory_movement = InventoryMovement.find_by(movement_type: "SALE", reference_id: self.id)
    if inventory_movement
      inventory_movement.destroy
    end
  end
end
