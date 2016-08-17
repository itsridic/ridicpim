class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  def index
    @orders = Order.order(user_date: :desc).paginate(page: params[:page], per_page: 3).includes(:contact, :order_items => :product)
  end

  def show
  end

  def new
    @order = Order.new
  end

  def edit
  end

  def create
    contact_name = params["order"]["contact_name"]
    @order = Order.new(order_params)
    @order.contact_id = create_new_contact(contact_name) if !contact_name.blank?

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end


  def order_params
    params.require(:order).permit(:name, :contact_id, :user_date, :contact_name, order_items_attributes: [:id, :cost, :quantity, :product_id, :order_id, :_destroy]).except(:contact_name)
  end

  def create_new_contact(name)
    c = Contact.create!(name: name)
    c.id
  end
end