class Product < ApplicationRecord
  belongs_to :bundle_product, class_name: "Product"

  validates :name, presence: true
  validates :amazon_sku, presence: true
  validates :price, presence: true

  def quantity_ordered
    OrderItem.where("product_id = ?", self.id).sum(:quantity)
  end

  def quantity_sold
    Sale.where("product_id = ?", self.id).sum(:quantity)
  end

  def quantity_adjusted
    Adjustment.where("product_id = ?", self.id).sum(:adjusted_quantity)
  end

  def on_hand
    quantity_ordered - quantity_sold + quantity_adjusted
  end

  def on_hand_by_location(location)
    InventoryMovement.where("product_id = ? AND location_id = ?", self.id, location.id).sum(:quantity)
  end

  def last_quantity_ordered
    if item_ordered?
      OrderItem.where("product_id = ?", self.id).last.quantity
    else
      0
    end
  end

  def last_cost
    if item_ordered?
      OrderItem.where("product_id = ?", self.id).last.cost / 
        OrderItem.where("product_id = ?", self.id).last.quantity
    else
      0
    end
  end

  def item_ordered?
    if OrderItem.where("product_id = ?", self.id).size != 0
      true
    else
      false
    end
  end

  def average_cost(date)
    if item_ordered?
      OrderItem.joins(:order).where("product_id = ? AND user_date <= ?", self.id, date).order("user_date DESC").first.try(:average_cost) || 0
    else
      0
    end
  end

  def bundle?
    self.bundle_product.present?
  end
end
