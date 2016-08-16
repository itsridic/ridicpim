class Product < ApplicationRecord
  validates :name, presence: true
  validates :amazon_sku, presence: true
  validates :price, presence: true
end
