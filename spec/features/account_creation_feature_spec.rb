require 'rails_helper'

feature 'account creation' do
	it 'allows user to create account' do
		visit root_path
		click_link 'Create Account'

		fill_in 'Name', with: 'Nate'
		fill_in 'Email', with: 'nate@itsridic.com'
		fill_in 'Password', with: 'password'
		fill_in 'Password confirmation', with: 'password'
		fill_in 'Subdomain', with: 'test_subdomain'
		click_button 'Create Account'

		expect(page).to have_content('Signed up successfully')
	end
end