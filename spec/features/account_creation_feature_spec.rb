require 'rails_helper'

feature 'account creation' do
	before(:each) do
    set_host("lvh.me:31234")
  end

	it 'allows user to create account', :js do
    subdomain = "subdomain"
    sign_up(subdomain)
		expect(page.current_url).to include(subdomain)
		expect(Account.all.count).to eq(1)
	end

	it 'allows access of subdomain', :js do
    subdomain = "subdomain"
    sign_up(subdomain)
		visit root_url(subdomain: subdomain)
		expect(page.current_url).to include(subdomain)
	end

	it 'allows account followup creation', :js do
    subdomain = "subdomain"
    sign_up(subdomain)
		subdomain2 = "subdomain2"
		sign_up(subdomain2)
		expect(page.current_url).to include(subdomain2)
		expect(Account.all.count).to eq(2)
	end

	def sign_up(subdomain)
    plan = FactoryGirl.create(:plan)
    user = FactoryGirl.build_stubbed(:user, name: "Nate", email: "nate@itsridic.com", password: "password", password_confirmation: "password")
    visit root_path(subdomain: false)
    click_link 'Create Account'
    fill_in 'Name', with: user.name
    fill_in 'Email', with: user.email
		fill_in 'Password', with: user.password
		fill_in 'Password confirmation', with: user.password_confirmation
		fill_in 'Subdomain', with: subdomain
		check 'account_accept_terms'
		token = Stripe::Token.create(
			:card => {
				:number => "4242424242424242",
				:exp_month => 7,
				:exp_year => 2019,
				:cvc => "314",
			}
		)
		page.execute_script("$('#payment_token').val('#{token.id}');")
		page.execute_script("$('#new_account').submit();")
  end
end

def set_host(host)
	default_url_options[:host] = host
	Capybara.app_host = "http://" + host
end
