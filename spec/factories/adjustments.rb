FactoryGirl.define do
  factory :adjustment do
    adjustment_type
    product
    adjusted_quantity -1
  end
end
