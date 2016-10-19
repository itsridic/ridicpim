class Adjustment < ApplicationRecord
  belongs_to :adjustment_type
  belongs_to :product
  belongs_to :location
  after_save :set_user_date, :create_inventory_movement
  after_destroy :remove_inventory_movement

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

  def create_inventory_movement
    inventory_movement = InventoryMovement.find_by(movement_type: "ADJUSTMENT", reference_id: self.id)
    if inventory_movement
      loc = self.location
      prod = self.product
      qty = self.adjusted_quantity
      inventory_movement.update(location: loc, product: prod, quantity: qty, movement_type: "ADJUSTMENT")
    else
      loc = self.location
      prod = self.product
      qty = self.adjusted_quantity
      InventoryMovement.create!(location: loc, product: prod, quantity: qty, movement_type: "ADJUSTMENT")      
    end
  end

  def remove_inventory_movement
    inventory_movement = InventoryMovement.find_by(movement_type: "ADJUSTMENT", reference_id: self.id)
    if inventory_movement
      inventory_movement.destroy
    end
  end
end
