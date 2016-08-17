FactoryGirl.define do
  factory :order_item do
    order
    product
    quantity 1
    cost 9.99
    average_cost nil
  end
end
