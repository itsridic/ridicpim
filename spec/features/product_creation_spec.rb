require 'rails_helper'

feature 'product CRUD' do
  let(:user) { build(:user) }
  let(:account) { create(:account_with_schema, owner: user) }

  before(:each) do
    set_host("lvh.me:31234")
  end

  scenario 'creation', :js do
    sign_user_in(user, subdomain: account.subdomain)
    click_on 'Products'
    click_on 'New Product'
    fill_in 'product[name]', with: "Test Product"
    fill_in 'product[amazon_sku]', with: "test_sku"
    fill_in 'product[price]', with: 9.99
    click_on 'Create Product'
    
    expect(page).to have_content('Test Product')
  end

  # scenario 'update', :js do
  #   sign_user_in(user, subdomain: account.subdomain)
  #   product = create(:product, name: "XXX")
  #   click_link('products')
  # end

end

def set_host(host)
  default_url_options[:host] = host
  Capybara.app_host = "http://" + host
end