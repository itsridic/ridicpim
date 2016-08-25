class SubdomainPresent
  def self.matches?(request)
    request.subdomain.present?
  end
end

class SubdomainBlank
  def self.matches?(request)
    request.subdomain.blank?
  end
end

Rails.application.routes.draw do
  constraints(SubdomainPresent) do
    root 'dashboard#show', as: :subdomain_root
    devise_for :users
    resources :users, only: [:index]
    resources :products
    resources :contacts
    resources :orders
    resources :payments
    resources :sales_receipts
    resources :adjustment_types
    resources :adjustments
    resources :credentials
    resources :qbo_accounts
    resources :inventory, only: [:index]
    resources :expense_receipts
    resources :amazon_statements, only: [:index, :show] do
      collection do
        get :fetch
      end
    end
    resources :quick_books, only: [] do
      collection do
        get :authenticate
        get :oauth_callback
      end
    end
  end
  
  constraints(SubdomainBlank) do
    root 'welcome#index'
	  resources :accounts, only: [:new, :create]
  end
end
