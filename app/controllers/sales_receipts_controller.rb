class SalesReceiptsController < ApplicationController
  before_action :set_receipt, only: [:show, :edit, :update, :destroy]
  after_action :recalculate_average_cost, only: [:create, :update, :destroy]

  def index
    @sales_receipts = SalesReceipt.order(user_date: :desc).paginate(page: params[:page], per_page: 10).includes(:contact, :location)
  end

  def show
  end

  def new
    @sales_receipt = SalesReceipt.new
  end

  def edit
  end

  def update
    respond_to do |format|
      if @sales_receipt.update(sales_receipt_params)
        create_update_sales_receipt_in_qbo(@sales_receipt) if @sales_receipt.qbo_id.present?
        format.html { redirect_to @sales_receipt, notice: 'Sales Receipt was successfully updated.' }
        format.json { render :show, status: :ok, location: @sales_receipt }
      else
        format.html { render :edit }
        format.json { render json: @sales_receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  def create  
    @sales_receipt = SalesReceipt.new(sales_receipt_params)

    respond_to do |format|
      if @sales_receipt.save
        create_update_sales_receipt_in_qbo(@sales_receipt)
        format.html { redirect_to @sales_receipt, notice: 'Sales Receipt was successfully created.' }
        format.json { render :show, status: :created, location: @sales_receipt }
      else
        format.html { render :new }
        format.json { render json: @sales_receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # Remove from QBO
    unless @sales_receipt.qbo_id.nil?
      qbo_rails = QboRails.new(QboConfig.last, :sales_receipt)
      qbo_rails.delete(@sales_receipt)
    end

    @sales_receipt.destroy
    respond_to do |format|
      format.html { redirect_to sales_receipts_path, alert: 'Sales Receipt was successfully destroyed.' }
      format.js   {}
      format.json { head :no_content }
    end
  end

  private

  def set_receipt
    @sales_receipt = SalesReceipt.find(params[:id])
  end

  def sales_receipt_params
    params.require(:sales_receipt).permit(:contact_id, :payment_id, :location_id, :user_date, sales_attributes: [:id, :quantity, :product_id, :sales_receipt_id, :amount, :rate, :description, :_destroy])
  end

  def recalculate_average_cost
    Order.where("user_date > ?", @sales_receipt.user_date).order("user_date").each do |order|
      order.order_items.each do |oi|
        if oi.trigger_update.nil?
          oi.trigger_update = true
          oi.save
        else
          oi.trigger_update = !oi.trigger_update
          oi.save
        end
      end
    end
  end

  def create_update_sales_receipt_in_qbo(sales_receipt)
    qbo_rails = QboRails.new(QboConfig.last, :sales_receipt)
    qbo_receipt = qbo_rails.base.qr_model(:sales_receipt)
    qbo_receipt.customer_id = sales_receipt.contact.qbo_id
    qbo_receipt.txn_date = Date.parse(sales_receipt.user_date.to_s)
    qbo_receipt.deposit_to_account_id = current_account.settings(:sales_receipt_deposit_to_account).val
    date_time = sales_receipt.user_date.strftime("%m-%d-%Y")
    qbo_receipt.doc_number = date_time
    qbo_receipt.payment_ref_number = date_time

    sales_receipt.sales.each do |sale|
      line_item = qbo_rails.base.qr_model(:line)
      line_item.amount = sale.amount.to_f
      line_item.description = sale.description
      line_item.sales_item! do |detail|
        unless sale.quantity * sale.rate == line_item.amount
          sale.amount = sale.quantity * sale.rate
          sale.save!
          line_item.amount = sale.quantity * sale.rate
        end
        detail.unit_price = sale.rate.to_f
        detail.quantity = sale.quantity
        detail.item_id = sale.product.qbo_id if sale.product.present?
      end
      qbo_receipt.line_items << line_item
    end
    created_receipt = qbo_rails.create_or_update(sales_receipt, qbo_receipt)
  end
end
