class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :load_schema, :authenticate_user!, :set_mailer_host
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_active_status, unless: :devise_controller?

  def set_client
    MWS::Reports::Client.new(
      primary_marketplace_id: Credential.last.primary_marketplace_id,
      merchant_id: Credential.last.merchant_id,
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      auth_token: Credential.last.auth_token
    )
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:name])
  end

  private

  def load_schema
    Apartment::Tenant.switch!('public')
    return unless request.subdomain.present?

    if current_account
      Apartment::Tenant.switch!(current_account.subdomain)
    else
      redirect_to root_url(subdomain: false)
    end
  end

  def current_account
    @current_account ||= Account.find_by(subdomain: request.subdomain)
  end
  helper_method :current_account


  def set_mailer_host
    subdomain = current_account ? "#{current_account.subdomain}." : ""
    ActionMailer::Base.default_url_options[:host] = "#{subdomain}retailmerge.com"
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def after_invite_path_for(resource)
    users_path
  end

  def check_active_status
    if current_account.inactive?
      redirect_to inactive_accounts_path, notice: "This account has been cancelled"
    end
  end
end
