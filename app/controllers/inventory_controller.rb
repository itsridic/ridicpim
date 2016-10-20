class InventoryController < ApplicationController
  def index
    @products = Product.all.order("name")
    @locations = Location.all.order("name")
  end
end
