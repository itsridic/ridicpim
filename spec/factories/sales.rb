FactoryGirl.define do
  factory :sale do
    sales_receipt
    product
    quantity 300
    amount 3000
  end
end
