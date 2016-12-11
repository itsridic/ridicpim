class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  def index
    @orders = Order.order(user_date: :desc)
                   .paginate(page: params[:page], per_page: 3)
                   .includes(:contact, order_items: :product)
  end

  def show() end

  def new
    @order = Order.new
    @product = Product.new
  end

  def edit() end

  def create
    contact_name = params['order']['contact_name']
    @order = Order.new(order_params)

    unless contact_name.blank?
      @order.contact_id = create_new_contact(contact_name)
    end

    if @order.save
      expense_receipt = CreateExpenseReceipt.in_app_from_order(@order)
      CreateExpenseReceipt.in_qbo(expense_receipt, @order.qbo_account_id)
      redirect_to @order, notice: 'Order was successfully created.'
    end
  end

  def update
    if @order.update(order_params)
      redirect_to @order, notice: 'Order was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @order.destroy
    respond_to do |format|
      format.js {}
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order)
          .permit(:name, :contact_id, :location_id, :user_date, :qbo_account_id,
                  :contact_name,
                  order_items_attributes: [:id, :cost, :quantity,
                                           :product_id, :order_id,
                                           :_destroy]).except(:contact_name)
  end

  def create_new_contact(name)
    c = Contact.create!(name: name)
    c.id
  end

  def create_expense_in_qbo
    qbo_rails = QboRails.new(QboConfig.last, :purchase)
    purchase = qbo_rails.base.qr_model(:purchase)
    purchase.txn_date = @order.user_date
    purchase.account_id = QboAccount.find(@order.qbo_account_id).qbo_id
    purchase.line_items = []
    @order.order_items.each do |oi|
      line_item = qbo_rails.base.qr_model(:purchase_line_item)
      line_item.amount = oi.cost
      line_item.description = @order.name
      line_item.account_based_expense! do |detail|
        detail.account_id = expense.qbo_account.qbo_id
      end
      purchase.line_items << line_item
    end
    qbo_rails.create(purchase)
  end
end
