Rails.application.routes.draw do
  devise_for :users
	resources :accounts
  root 'welcome#index'
end
