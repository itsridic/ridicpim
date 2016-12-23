FactoryGirl.define do
  factory :transfer_item do
    transfer nil
    product nil
    from_location 1
    to_location 1
    description "MyText"
  end
end
