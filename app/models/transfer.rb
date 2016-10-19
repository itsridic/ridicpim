class Transfer < ApplicationRecord
  belongs_to :product
  after_save :create_inventory_movement
  after_destroy :remove_inventory_movement

  private

  def create_inventory_movement
    from_loc = self.from_location_id
    to_loc = self.to_location_id
    product = self.product
    qty = self.quantity

    inventory_movements = InventoryMovement.where("movement_type = ? AND reference_id = ?", "TRANSFER", self.id).order("id")
    if inventory_movements.any?
      inventory_movements.destroy_all
      InventoryMovement.create!(location: Location.find(from_loc), product: product, quantity: qty *-1, movement_type: "TRANSFER", reference_id: self.id)
      InventoryMovement.create!(location: Location.find(to_loc), product: product, quantity: qty, movement_type: "TRANSFER", reference_id: self.id)
    else
      InventoryMovement.create!(location: Location.find(from_loc), product: product, quantity: qty *-1, movement_type: "TRANSFER", reference_id: self.id)
      InventoryMovement.create!(location: Location.find(to_loc), product: product, quantity: qty, movement_type: "TRANSFER", reference_id: self.id)
    end
  end

  def remove_inventory_movement
    inventory_movements = InventoryMovement.where("movement_type = ? AND reference_id = ?", "TRANSFER", self.id).order("id")
    inventory_movements.destory_all
  end
end
