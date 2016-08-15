require 'rails_helper'

feature 'subdomain' do
  let(:account) { create(:account_with_schema) }

  it 'redirects invalid accounts' do
    visit root_url(subdomain: 'random-subdomain')
    expect(page.current_url).not_to include('random-subdomain')
  end

  it 'allows valid accounts' do
    visit root_url(subdomain: account.subdomain)
    expect(page.current_url).to include(account.subdomain)
  end

  it 'forces users to login before accessing subdomain content' do
    visit root_url(subdomain: account.subdomain)
    expect(page).to have_content('sign in or sign up before continuing')
  end
end