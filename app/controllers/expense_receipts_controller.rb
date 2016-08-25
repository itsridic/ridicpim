class ExpenseReceiptsController < ApplicationController
  before_action :set_expense_receipt, only: [:show, :edit, :update, :destroy]

  def index
    @expense_receipts = ExpenseReceipt.order(user_date: :desc).paginate(page: params[:page], per_page: 10)
  end

  def show
  end

  def new
    @expense_receipt = ExpenseReceipt.new
  end

  def edit
  end

  def create
    @expense_receipt = ExpenseReceipt.new(expense_receipt_params)

    respond_to do |format|
      if @expense_receipt.save
        format.html { redirect_to @expense_receipt, notice: 'Expense receipt was successfully created.' }
        format.json { render :show, status: :created, location: @expense_receipt }
      else
        format.html { render :new }
        format.json { render json: @expense_receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @expense_receipt.update(expense_receipt_params)
        format.html { redirect_to @expense_receipt, notice: 'Expense receipt was successfully updated.' }
        format.json { render :show, status: :ok, location: @expense_receipt }
      else
        format.html { render :edit }
        format.json { render json: @expense_receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @expense_receipt.destroy
    respond_to do |format|
      format.html { redirect_to expense_receipts_url, notice: 'Expense receipt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_expense_receipt
    @expense_receipt = ExpenseReceipt.find(params[:id])
  end

  def expense_receipt_params
    params.require(:expense_receipt).permit(:description, :user_date, expenses_attributes: [:id, :description, :amount, :qbo_account_id, :_destroy])
  end
end
