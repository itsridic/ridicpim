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
  get '/tos' => 'welcome#tos'
  constraints(SubdomainPresent) do
    root 'dashboard#show', as: :subdomain_root
    devise_for :users
    resources :users, only: [:index]
    resources :orders
    resources :payments
    resources :sales_receipts
    resources :adjustment_types
    resources :adjustments
    resources :credentials
    resources :inventory, only: [:index]
    resources :expense_receipts
    resources :locations
    resources :transfers
    resources :contacts do
      collection do
        get :fetch
      end
    end
    resources :qbo_accounts do
      collection do
        get :fetch
      end
    end
    resources :settings, only: [:index] do
      collection do
        put :change
      end
    end
    resources :amazon_statements, only: [:index, :show] do
      collection do
        get :fetch
      end
    end
    resources :products do
      collection do
        get :fetch
        get :fetch_mws
      end
    end
    resources :quick_books, only: [] do
      collection do
        get :authenticate
        get :oauth_callback
      end
    end
    resource :accounts, only: [:show, :edit, :update] do
      get :inactive
      post :reactivate
      resource :cancellation, only: [:new, :create]
    end
  end

  constraints(SubdomainBlank) do
    root 'welcome#index'
	  resources :accounts, only: [:new, :create]
  end
end
