class AccountsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  skip_before_action :check_active_status,
                     only: [:inactive, :new, :create, :reactivate]
  before_action :set_plan,
                only: [:create, :inactive, :reactivate, :new, :show, :edit]
  before_action :set_account,
                only: [:show, :edit, :update, :inactive, :reactivate]

  def new
    @account = Account.new
    @account.build_owner
  end

  def show() end

  def edit() end

  def update
    if @account.update_account(@account, params[:stripeToken])
      redirect_to subdomain_root_path, notice: 'Your card has been updated!'
    else
      render :edit
    end
  end

  def create
    @account = Account.new(account_params)
    if @account.save_with_payment(@plan, params[:stripeToken],
                                  params[:stripeEmail])
      redirect_to new_user_session_url(subdomain: @account.subdomain),
                  notice: 'Your account was created successfully'
    else
      render :new
    end
  end

  def inactive() end

  def reactivate
    if @account.reactivate_account(@plan, params[:stripeToken])
      redirect_to subdomain_root_path, notice: 'Thank you for your payment!'
    else
      render :inactive
    end
  end

  private

  def set_plan
    @plan = Plan.first || Plan.new(stripe_id: 1000, name: "Standard Plan", price: 1999, trial_period_days: 30)
  end

  def set_account
    @account = current_account
  end

  def account_params
    params.require(:account)
          .permit(:subdomain, :accept_terms, owner_attributes:
            [:name, :email, :password, :password_confirmation])
  end
end
