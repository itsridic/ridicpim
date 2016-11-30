FactoryGirl.define do
  factory :plan do
    stripe_id 1
    name "MyString"
    price 1
    trial_period_days 1
  end
end
