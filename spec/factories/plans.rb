FactoryGirl.define do
  factory :plan do
    stripe_id 1000
    name "Standard Plan"
    price 1999
    trial_period_days 30
  end
end
