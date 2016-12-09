FactoryGirl.define do
  factory :plan do
    stripe_id 1000
    name "Standard Plan"
    price 19.99
    trial_period_days 1
  end
end
