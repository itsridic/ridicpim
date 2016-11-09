class Sale < ApplicationRecord
  belongs_to :product
  belongs_to :sales_receipt
  after_save :set_rate, :create_inventory_movement
  after_destroy :remove_inventory_movement

  validates :quantity, presence: true
  validates :amount, presence: true

  validate :product_and_description

  default_scope { order(:id) }
  
  private

  def product_and_description
    if product.blank? and description.blank?
      errors.add(:line, "must specify a product or description")
    end
  end

  def set_rate
    self.update_column(:rate, amount.to_f / quantity.to_f)
  end

  def create_inventory_movement
    inventory_movement = InventoryMovement.find_by(movement_type: "SALE", reference_id: self.id)
    if inventory_movement
      prod = self.product
      unless prod.nil?
        loc = self.sales_receipt.location
        qty = self.quantity * -1
        inventory_movement.update(location: loc, product: prod, quantity: qty, movement_type: "SALE", reference_id: self.id)
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
