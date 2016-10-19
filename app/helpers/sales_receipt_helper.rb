module SalesReceiptHelper
  def sale_location(sales_receipt)
    if sales_receipt.location.nil?
      ""
    else
      sales_receipt.location.name
    end
  end
end