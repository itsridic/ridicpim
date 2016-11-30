require 'apartment/sidekiq/railtie'
Apartment::Sidekiq::Middleware.run

Apartment.configure do |config|
  config.excluded_models = ['Account','Plan','Cancellation']
  config.tenant_names = lambda{ Account.pluck(:subdomain) }
end
