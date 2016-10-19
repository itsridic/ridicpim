module OrderHelper
  def order_location(order)
    if order.location.nil?
      ""
    else
      order.location.name
    end
  end
end
