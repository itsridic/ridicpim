class PaymentsController < ApplicationController
  respond_to :json, only: [:create, :edit, :update, :destroy]

  def index
    load_payments
  end

  def show
    load_payment
  end

  def edit
    load_payment
  end

  def create
    build_payment
    save_payment
  end

  def update
    load_payment
    build_payment
    save_payment
  end

  def destroy
    load_payment
    @payment.destroy
  end

  private

  def payment_params
    payment_params = params[:payment]
    if payment_params
      params.require(:payment).permit(:name)
    else
      {}
    end
  end

  def load_payment
    @payment ||= payment_scope.find(params[:id])
  end

  def load_payments
    @payments ||= payment_scope
  end

  def build_payment
    @payment ||= payment_scope.build
    @payment.attributes = payment_params
  end

  def save_payment
    unless @payment.save
      render action: 'failure'
    end
  end

  def payment_scope
    Payment.all
  end
end
