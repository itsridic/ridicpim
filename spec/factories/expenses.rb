FactoryGirl.define do
  factory :expense do
    expense_receipt nil
    qbo_account nil
    description "MyString"
    amount "9.99"
  end
end
