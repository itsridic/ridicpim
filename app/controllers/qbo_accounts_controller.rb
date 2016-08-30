class QboAccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  def index
    @qbo_accounts = QboAccount.all.order("name")
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
        # Create / Update Account in QBO
        qbo_rails = QboRails.new(QboConfig.last, :account)
        qb_account = qbo_rails.base.qr_model(:account)
        qb_account.name = @qbo_account.name
        qb_account.account_type = @qbo_account.account_type
        qb_account.classification = classify_account(@qbo_account.account_type)
        qbo_rails.create_or_update(@qbo_account, qb_account)

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
        # Create / Update Account in QBO
        qbo_rails = QboRails.new(QboConfig.last, :account)
        qb_account = qbo_rails.base.qr_model(:account)
        qb_account.name = @qbo_account.name
        qb_account.account_type = @qbo_account.account_type
        qb_account.classification = classify_account(@qbo_account.account_type)
        qbo_rails.create_or_update(@qbo_account, qb_account)

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

  def fetch
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, QboConfig.first.token, QboConfig.first.secret)
    account_service = Quickbooks::Service::Account.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)
    query = "SELECT * FROM Account WHERE active = true"
    account_service.query_in_batches(query, per_page: 1000) do |batch|
      batch.each do |account|
        if QboAccount.where(name: account.name).count == 0
          QboAccount.create!(name: account.name, account_type: account.account_type, qbo_id: account.id)
        end
      end
    end
    redirect_to accounts_path
  end

  private

  def classify_account(account_type)
    mapping = {
      "Bank" => "Asset", "Other Current Asset" => "Asset", "Fixed Asset" => "Asset", "Other Asset" => "Asset", "Accounts Receivable" => "Asset",
      "Equity" => "Equity",
      "Expense" => "Expense", "Other Expense" => "Expense", "Cost Of Goods Sold" => "Expense",
      "Accounts Payable" => "Liability", "Credit Card" => "Liability", "Long Term Liability" => "Liability", "Other Current Liability" => "Liability",
      "Income" => "Revenue", "Other Income" => "Revenue"
    }
    mapping[account_type]
  end

  def set_account
    @qbo_account = QboAccount.find(params[:id])
  end

  def account_params
    params.require(:qbo_account).permit(:name, :account_type, :qbo_id)
  end
end