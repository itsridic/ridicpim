class AddAcceptTermsToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :accept_terms, :boolean
  end
end
