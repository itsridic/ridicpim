class SalesReceiptsController < ApplicationController
  respond_to :json, only: [:index]
  after_action :recalculate_average_cost, only: [:create, :update, :destroy]

  def index
    load_sales_receipts
  end

  def show
    load_sales_receipt
  end

  def new
    build_sales_receipt
  end

  def edit
    load_sales_receipt
  end

  def create
    build_sales_receipt
    save_sales_receipt('Sales Receipt Created Successfully') || (render :new)
  end

  def update
    load_sales_receipt
    build_sales_receipt
    save_sales_receipt('Sales Receipt Updated Successfully') || (render :edit)
  end

  def destroy
    load_sales_receipt
    destroy_sales_receipt
  end

  private

  def sales_receipt_params
    sales_receipt_params = params[:sales_receipt]
    if sales_receipt_params
      sales_receipt_params.permit(:contact_id, :payment_id, :location_id,
                                  :user_date, sales_attributes:
                                  [:id, :quantity, :product_id,
                                   :sales_receipt_id, :amount, :rate,
                                   :description, :_destroy])
    else
      {}
    end
  end

  def load_sales_receipts
    @sales_receipts ||= sales_receipt_scope
                        .paginate(page: params[:page], per_page: 10)
                        .includes(:contact, :location)
  end

  def load_sales_receipt
    @sales_receipt ||= sales_receipt_scope.find(params[:id])
  end

  def build_sales_receipt
    @sales_receipt ||= sales_receipt_scope.build
    @sales_receipt.attributes = sales_receipt_params
  end

  def save_sales_receipt(flash_message)
    if @sales_receipt.save
      create_update_sales_receipt_in_qbo(@sales_receipt)
      redirect_to @sales_receipt, notice: flash_message
    end
  end

  def destroy_sales_receipt
    unless @sales_receipt.qbo_id.nil?
      qbo_rails = QboRails.new(QboConfig.last, :sales_receipt)
      qbo_rails.delete(@sales_receipt)
    end
    @sales_receipt.destroy
    redirect_to sales_receipts_path,
                notice: 'Sales Receipt Successfully Deleted'
  end

  def sales_receipt_scope
    SalesReceipt.all
  end

  def recalculate_average_cost
    Order.by_date(@sales_receipt.user_date).each do |order|
      order.order_items.each do |oi|
        if oi.trigger_update.nil?
          oi.trigger_update = true
        else
          oi.trigger_update = !oi.trigger_update
        end
        oi.save
      end
    end
  end

  def add_existing_product_to_qbo(product)
    qbo_rails = QboRails.new(QboConfig.last, :sales_receipt)
    qbo_rails_item = QboRails.new(QboConfig.last, :item)
    qb_item = qbo_rails.base.qr_model(:item)
    qb_item.income_account_id = current_account
                                .settings(:sales_receipt_income_account).val
    qb_item.attributes.update(
      type: 'NonInventory', name: product.name, description: product.name,
      unit_price: product.price, sku: product.amazon_sku
    )
    qbo_rails_item.create_or_update(product, qb_item)
  end

  def create_update_sales_receipt_in_qbo(sales_receipt)
    qbo_rails = QboRails.new(QboConfig.last, :sales_receipt)
    qbo_receipt = qbo_rails.base.qr_model(:sales_receipt)
    qbo_receipt.customer_id = sales_receipt.contact.qbo_id
    qbo_receipt.txn_date = Date.parse(sales_receipt.user_date.to_s)
    qbo_receipt.deposit_to_account_id =
      current_account.settings(:sales_receipt_deposit_to_account).val
    date_time = sales_receipt.user_date.strftime('%m-%d-%Y')
    qbo_receipt.doc_number = date_time
    qbo_receipt.payment_ref_number = date_time

    sales_receipt.sales.each do |sale|
      if sale.product && sale.product.qbo_id.nil?
        add_existing_product_to_qbo(sale.product)
      end
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
    qbo_rails.create_or_update(sales_receipt, qbo_receipt)
  end
end
