class SalesReceiptsController < ApplicationController
  before_action :set_receipt, only: [:show, :edit, :update, :destroy]
  after_action :recalculate_average_cost, only: [:create, :update, :destroy]

  def index
    @sales_receipts = SalesReceipt.order(user_date: :desc).paginate(page: params[:page], per_page: 10).includes(:contact, :location, :sales => :product)
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
        format.html { redirect_to @sales_receipt, notice: 'Sales Receipt was successfully updated.' }
        format.json { render :show, status: :ok, location: @sales_receipt }
      else
        format.html { render :edit }
        format.json { render json: @sales_receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    # Clear empty rows
    params["sales_receipt"]["sales_attributes"].each do |k,v|
      if params["sales_receipt"]["sales_attributes"][k]["product_id"] == ""
        params["sales_receipt"]["sales_attributes"].delete(k)
      else
        if params["sales_receipt"]["sales_attributes"][k]["product_id"].to_i == 0
          params["sales_receipt"]["sales_attributes"][k]["description"] = params["sales_receipt"]["sales_attributes"][k]["product_id"]
          params["sales_receipt"]["sales_attributes"][k]["product_id"] = ""
        end
      end
    end

    p "*" * 100
    p params
    p "*" * 100
    
    @sales_receipt = SalesReceipt.new(sales_receipt_params)

    respond_to do |format|
      if @sales_receipt.save
        format.html { redirect_to @sales_receipt, notice: 'Sales Receipt was successfully created.' }
        format.json { render :show, status: :created, location: @sales_receipt }
      else
        format.html { render :new }
        format.json { render json: @sales_receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
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
end