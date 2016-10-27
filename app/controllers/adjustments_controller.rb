class AdjustmentsController < ApplicationController
  before_action :set_adjustment, only: [:show, :edit, :update, :destroy]
  #after_action :recalculate_average_cost, only: [:create, :update, :destroy]

  def index
    @adjustments = Adjustment.all.includes(:product, :adjustment_type, :location).order("created_at DESC")
    @adjustment = Adjustment.new
  end

  def show
  end

  def new
    @adjustment = Adjustment.new
  end

  def edit
  end

  def create
    @adjustment = Adjustment.new(adjustment_params)

    respond_to do |format|
      if @adjustment.save
        format.html { redirect_to @adjustment, notice: 'Adjustment was successfully created.' }
        format.js {}
        format.json { render :show, status: :created, location: @adjustment }
      else
        format.html { render :new }
        format.json { render json: @adjustment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @adjustment.update(adjustment_params)
        format.html { redirect_to @adjustment, notice: 'Adjustment was successfully updated.' }
        format.js {}
        format.json { render :show, status: :ok, location: @adjustment }
      else
        format.html { render :edit }
        format.json { render json: @adjustment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @adjustment.destroy
    respond_to do |format|
      format.html { redirect_to adjustments_url, notice: 'Adjustment was successfully destroyed.' }
      format.js {}
      format.json { head :no_content }
    end
  end

  private

  def set_adjustment
    @adjustment = Adjustment.find(params[:id])
  end

  def adjustment_params
    params.require(:adjustment).permit(:product_id, :adjustment_type_id, :adjusted_quantity, :user_date, :location_id)
  end

  # def recalculate_average_cost
  #   Order.where("user_date > ?", @adjustment.user_date).order("user_date").each do |order|
  #     order.order_items.each do |oi|
  #       if oi.trigger_update.nil?
  #         oi.trigger_update = true
  #         oi.save
  #       else
  #         oi.trigger_update = !oi.trigger_update
  #         oi.save
  #       end
  #     end
  #   end
  # end 
end
