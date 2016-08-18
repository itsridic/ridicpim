FactoryGirl.define do
  factory :sale do
    sales_receipt nil
    product nil
    quantity 1
    amount "9.99"
    rate "9.99"
    description "MyString"
    qbo_id 1
  end
end
