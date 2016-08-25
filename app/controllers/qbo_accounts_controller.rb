class QboAccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  def index
    @qbo_accounts = QboAccount.all
  end

  def show
  end

  def new
    @qbo_account = QboAccount.new
  end

  def edit
  end

  def create
    @qbo_account = QboAccount.new(account_params)

    respond_to do |format|
      if @qbo_account.save
        format.html { redirect_to @qbo_account, notice: 'Account was successfully created.' }
        format.js {}
        format.json { render :show, status: :created, location: @qbo_account }
      else
        format.html { render :new }
        format.json { render json: @qbo_account.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @qbo_account.update(account_params)
        format.html { redirect_to @qbo_account, notice: 'Account was successfully updated.' }
        format.js {}
        format.json { render :show, status: :ok, location: @qbo_account }
      else
        format.html { render :edit }
        format.json { render json: @qbo_account.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @qbo_account.destroy
    respond_to do |format|
      format.html { redirect_to accounts_url, notice: 'Account was successfully destroyed.' }
      format.js {}
      format.json { head :no_content }
    end
  end

  private

  def set_account
    @qbo_account = QboAccount.find(params[:id])
  end

  def account_params
    params.require(:qbo_account).permit(:name, :account_type, :qbo_id)
  end
end