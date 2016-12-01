class AccountsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  skip_before_action :check_active_status, only: [:inactive, :new, :create, :reactivate]
  before_action :set_plan, only: [:create, :inactive, :reactivate, :new, :show, :edit]

  def new
    @account = Account.new
    @account.build_owner
  end

  def show
    @account = current_account
  end

  def edit
    @account = current_account
  end

  def update
    @account = current_account
    if @account.update_account(@account, params[:stripeToken])
      redirect_to subdomain_root_path, notice: "Your card has been updated!"
    else
      render :edit
    end
  end

  def create
    @account = Account.new(account_params)
    if @account.save_with_payment(@plan, params[:stripeToken], params[:stripeEmail])
      redirect_to new_user_session_url(subdomain: @account.subdomain)
    else
      render :new
    end
  end

  def inactive
    @account = current_account
  end

  def reactivate
    @account = current_account
    if @account.reactivate_account(@plan, params[:stripeToken])
      redirect_to subdomain_root_path, notice: "Thank you for your payment!"
    else
      render :inactive
    end
  end

  private

  def set_plan
    @plan = Plan.first
  end

  def account_params
    params.require(:account).permit(:subdomain, owner_attributes: [:name, :email, :password, :password_confirmation])
  end
end
