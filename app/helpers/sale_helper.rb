module SaleHelper
  def show_product_or_description(sale)
    if sale.product.nil?
      sale.description
    else
      sale.product.name
    end
  end
end