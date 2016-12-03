QB_KEY = ENV["QB_KEY"]
QB_SECRET = ENV["QB_SECRET"]

$qb_oauth_consumer = OAuth::Consumer.new(QB_KEY, QB_SECRET, {
  :site                 => "https://oauth.intuit.com",
  :request_token_path   => "/oauth/v1/get_request_token",
  :authorize_url        => "https://appcenter.intuit.com/Connect/Begin",
  :access_token_path    => "/oauth/v1/get_access_token"
})

Quickbooks.sandbox_mode = true
Quickbooks.log = true
Quickbooks.logger = Rails.logger


Quickbooks::Base.configure do |c|
  c.persistent_token = 'token'
  c.persistent_secret = 'secret'
  c.persistent_company_id = 'realm_id'
end
