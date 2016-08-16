class QuickBooksController < ApplicationController
  def authenticate
    callback = oauth_callback_quick_books_url
    puts "callback: "
    p callback
    token = $qb_oauth_consumer.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = Marshal.dump(token)
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def oauth_callback
    at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    QboConfig.create(token: at.token, secret: at.secret, realm_id: params['realmId'])
    flash.notice = "Your QuickBooks account has been successfully linked."
    @msg = 'Redirecting. Please wait.'
    @url = subdomain_root_path
    render 'close_and_redirect', layout: false
  end
end
