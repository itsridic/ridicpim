class AccountsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  skip_before_action :check_active_status, only: [:inactive, :new, :create, :reactivate]

  def new
    @account = Account.new
    @account.build_owner
    @plan = Plan.first
  end

  def edit
    @account = current_account
    @plan = Plan.first
  end

  def create
    @plan = Plan.first
    @account = Account.new(account_params)
    if @account.valid?
      begin
        customer = Stripe::Customer.create(
          source: params[:stripeToken],
          email: params[:stripeEmail]
        )
        subscription = Stripe::Subscription.create(
          customer: customer.id,
          plan: @plan.stripe_id
        )
        Apartment::Tenant.create(@account.subdomain)
        Apartment::Tenant.switch!(@account.subdomain)
        @account.sub_token = subscription.id
        @account.save
        user = @account.owner
        user.stripe_customer_id = customer.id
        user.save
      rescue Stripe::StripeError => e
        @account.errors[:base] << e.message
      end
      redirect_to new_user_session_url(subdomain: @account.subdomain)
    else
      render :new
    end
  end

  def inactive
    @plan = Plan.first
    @user = current_account.owner
  end

  def reactivate
    @plan = Plan.first
    @user = current_account.owner
    customer = Stripe::Customer.retrieve(@user.stripe_customer_id)
    subscription = Stripe::Subscription.create(
      customer: customer.id,
      plan: @plan.stripe_id
    )
    current_account.sub_token = subscription.id
    current_account.active = true
    current_account.save
    redirect_to subdomain_root_path, notice: "Thank you for your payment!"
  end

  private

  def account_params
    params.require(:account).permit(:subdomain, owner_attributes: [:name, :email, :password, :password_confirmation])
  end
end
