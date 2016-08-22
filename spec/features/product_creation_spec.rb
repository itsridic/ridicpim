require 'rails_helper'

feature 'user creates product' do
  let(:user) { build(:user) }
  let(:account) { create(:account_with_schema, owner: user) }

  before(:each) do
    set_host("lvh.me:31234")
  end

  scenario 'successfully', :js do
    product = build_stubbed(:product, name: 'Test Product', amazon_sku: 'test_sku', price: 9.99)
    sign_user_in(user, subdomain: account.subdomain)
    click_on 'Products'
    click_on 'New Product'
    fill_in 'product[name]', with: product.name
    fill_in 'product[amazon_sku]', with: product.amazon_sku
    fill_in 'product[price]', with: product.price
    click_on 'Create Product'
    
    expect(page).to have_content('Test Product')
  end
end

def set_host(host)
  default_url_options[:host] = host
  Capybara.app_host = "http://" + host
end