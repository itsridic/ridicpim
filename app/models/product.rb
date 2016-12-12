class Product < ApplicationRecord
  belongs_to :bundle_product, class_name: "Product"

  validates :name, presence: true
  validates :amazon_sku, presence: true, uniqueness: true
  validates :price, presence: true

  default_scope -> { order(:name) }
  scope :needs_inventory_asset, -> { where(bundle_product_id: nil, inventory_asset_account_id: nil) }
  scope :find_by_amazon_sku, ->(sku) { where("amazon_sku = ?", sku) }

  def self.create_inventory_asset_account(current_account, account_service, product)
    return product if product.inventory_asset_account_id.present?
    inventory_asset_account_id = current_account.settings(:inventory_asset).val
    account = account_service.query("SELECT * FROM Account WHERE name = 'Inventory - #{product.amazon_sku}'")
    p account
    p account.entries
    p account.entries.size
    if account.entries.count == 0
      qbo_rails = QboRails.new(QboConfig.last, :account)
      new_account = qbo_rails.base.qr_model(:account)
      new_account.name = "Inventory - #{product.amazon_sku}"
      new_account.classification = "Asset"
      new_account.parent_id = inventory_asset_account_id
      new_account.account_type = "Other Current Asset"
      new_account.account_sub_type = "Inventory"
      result = qbo_rails.create(new_account)
      product.inventory_asset_account_id = result.id
      product.save
      QboAccount.create_account_from_response(result)
    end
    return product
  end

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
