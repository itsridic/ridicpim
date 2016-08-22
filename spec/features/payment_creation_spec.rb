require 'rails_helper'

feature 'user creates payment' do
  let(:user) { build(:user) }
  let(:account) { create(:account_with_schema, owner: user) }

  before(:each) do
    set_host("lvh.me:31234")
  end

  scenario 'successfully', :js do
    payment = build_stubbed(:payment, name: 'Test Payment')
    sign_user_in(user, subdomain: account.subdomain)
    click_on 'Payments'
    click_on 'New Payment'
    fill_in 'payment[name]', with: payment.name
    click_on 'Create Payment'
    
    expect(page).to have_content('Test Payment')
  end
end

def set_host(host)
  default_url_options[:host] = host
  Capybara.app_host = "http://" + host
end