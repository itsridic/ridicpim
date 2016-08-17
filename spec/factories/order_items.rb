FactoryGirl.define do
  factory :order_item do
    order nil
    product nil
    quantity 1
    cost "9.99"
    average_cost "9.99"
  end
end
