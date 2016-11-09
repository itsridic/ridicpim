require 'rails_helper'

feature 'user creates product' do
  let(:user) { build(:user) }
  let(:account) { create(:account_with_schema, owner: user) }

  before(:each) do
    set_host("lvh.me:31234")
  end

  it 'allows navigation to the dashboard' do
    visit root_path
    expect(page.status_code).to eq(200)
  end

  it 'allows navigation to to products' do
    sign_user_in(user, subdomain: account.subdomain)
    click_link('products')

    expect(current_path).to eq(products_path)
  end

  it 'allows navigation to to contacts' do
    sign_user_in(user, subdomain: account.subdomain)
    click_link('contacts')
    
    expect(current_path).to eq(contacts_path)
  end

  it 'allows navigation to to orders' do
    sign_user_in(user, subdomain: account.subdomain)
    click_link('orders')
    
    expect(current_path).to eq(orders_path)
  end

  it 'allows navigation to to payments' do
    sign_user_in(user, subdomain: account.subdomain)
    click_link('payments')
    
    expect(current_path).to eq(payments_path)
  end

  it 'allows navigation to to sales' do
    sign_user_in(user, subdomain: account.subdomain)
    click_link('sales')
    
    expect(current_path).to eq(sales_receipts_path)
  end

  it 'allows navigation to to adjustments' do
    sign_user_in(user, subdomain: account.subdomain)
    click_link('adjustments')
    
    expect(current_path).to eq(adjustments_path)
  end

  it 'allows navigation to to credentials' do
    sign_user_in(user, subdomain: account.subdomain)
    click_link('credentials')
    
    expect(current_path).to eq(credentials_path)
  end

  it 'allows navigation to to inventory' do
    sign_user_in(user, subdomain: account.subdomain)
    click_link('inventory')
    
    expect(current_path).to eq(inventory_index_path)
  end

  it 'allows navigation to to accounts' do
    sign_user_in(user, subdomain: account.subdomain)
    click_link('accounts')
    
    expect(current_path).to eq(qbo_accounts_path)
  end

  it 'allows navigation to to expenses' do
    sign_user_in(user, subdomain: account.subdomain)
    click_link('expenses')
    
    expect(current_path).to eq(expense_receipts_path)
  end

  it 'allows navigation to to amazon statements' do
    sign_user_in(user, subdomain: account.subdomain)
    click_link('statements')
    
    expect(current_path).to eq(amazon_statements_path)
  end

  it 'allows navigation to to settings' do
    sign_user_in(user, subdomain: account.subdomain)
    click_link('settings')
    
    expect(current_path).to eq(settings_path)
  end

  it 'allows navigation to to locations' do
    sign_user_in(user, subdomain: account.subdomain)
    click_link('locations')
    
    expect(current_path).to eq(locations_path)
  end

  it 'allows navigation to to transfers' do
    sign_user_in(user, subdomain: account.subdomain)
    click_link('transfers')
    
    expect(current_path).to eq(transfers_path)
  end
end

def set_host(host)
  default_url_options[:host] = host
  Capybara.app_host = "http://" + host
end