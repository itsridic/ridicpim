FactoryGirl.define do
  factory :order_item do
    order
    product
    quantity 500
    cost 500.00
  end
end
