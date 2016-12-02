class Order < ApplicationRecord
  belongs_to :contact
  belongs_to :location
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true
  after_save :set_user_date, :update_inventory_movement

  validates :name, presence: true
  validates :contact, presence: true
  validates :location, presence: true

  private

  def set_user_date
    if user_date.blank?
      self.update_column(:user_date, self.created_at)
    end
  end

  def update_inventory_movement
    loc = self.location
    self.order_items.each do |order_item|
      begin
        InventoryMovement.find_by(movement_type: "ORDER", reference_id: order_item.id).update(location: loc)
      rescue Exception => e
        puts "Could not update!"
      end
    end
  end
end
