require "rails_helper"

feature "Product CRUD" do
  #let(:user) { build(:user) }
  #let(:account) { create(:account_with_schema, owner: user) }

  before(:each) do
    set_host("lvh.me:31234")
    user = build(:user)
    account = create(:account_with_schema, owner: user)
    sign_user_in(user, subdomain: account.subdomain)
    Apartment::Tenant.switch! account.subdomain     
  end

  after(:each) do
    Apartment::Tenant.reset
  end

  scenario "create", :js do
    click_on "Products"
    click_on "New Product"
    fill_in "product[name]", with: "Test Product"
    fill_in "product[amazon_sku]", with: "test_sku"
    fill_in "product[price]", with: 9.99
    click_on "Create Product"
    
    expect(page).to have_content("Test Product")
  end

  scenario "read", :js do
    product = create(:product, name: "My Product")
    click_link("products")
    click_link("show_product_#{product.id}")

    expect(current_path).to eq(product_path(product))
    expect(page).to have_content "My Product"
  end  

  scenario "update", :js do
    product = create(:product, name: "XXX")
    click_link("products")
    click_link("edit_product_#{product.id}")
    fill_in "product[name]", with: "XXX XXX"
    click_on "Update Product"

    expect(page).to have_content("XXX XXX")
  end

  scenario "delete", :js do
    product = create(:product, name: "DELETE ME")
    click_link("products")
    click_link("delete_product_#{product.id}")

    expect(page).not_to have_content("DELETE ME")
  end
end

def set_host(host)
  default_url_options[:host] = host
  Capybara.app_host = "http://" + host
end
