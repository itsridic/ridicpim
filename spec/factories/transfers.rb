FactoryGirl.define do
  factory :transfer do
    from_location_id 1
    to_location_id 1
    quantity 1
    description "MyText"
  end
end
