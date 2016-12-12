class AdjustmentsController < ApplicationController
  respond_to :json, only: [:create, :edit, :update, :destroy]
  #after_action :recalculate_average_cost, only: [:create, :update, :destroy]

  def index
    load_adjustments
    build_adjustment
  end

  def show
    load_adjustment
  end

  def edit
    load_adjustment
  end

  def create
    build_adjustment
    save_adjustment
  end

  def update
    load_adjustment
    build_adjustment
    save_adjustment
  end

  def destroy
    load_adjustment
    @adjustment.destroy
  end

  private

  def adjustment_params
    adjustment_params = params[:adjustment]
    if adjustment_params
      adjustment_params.permit(:product_id, :adjustment_type_id,
                               :adjusted_quantity, :user_date, :location_id)
    else
      {}
    end
  end

  def load_adjustments
    @adjustments ||= adjustment_scope
  end

  def load_adjustment
    @adjustment ||= adjustment_scope.find(params[:id])
  end

  def build_adjustment
    @adjustment ||= adjustment_scope.build
    @adjustment.attributes = adjustment_params
  end

  def save_adjustment
    unless @adjustment.save
      render action: 'failure'
    end
  end

  def adjustment_scope
    Adjustment.all.includes(:product, :adjustment_type, :location)
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
