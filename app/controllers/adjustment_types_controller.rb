class AdjustmentTypesController < ApplicationController
  before_action :set_adjustment_type, only: [:show, :edit, :update, :destroy]

  def index
    @adjustment_types = AdjustmentType.all
  end

  def show
  end

  def new
    @adjustment_type = AdjustmentType.new
  end

  def edit
  end

  def create
    @adjustment_type = AdjustmentType.new(adjustment_type_params)

    respond_to do |format|
      if @adjustment_type.save
        format.html { redirect_to @adjustment_type, notice: 'Adjustment type was successfully created.' }
        format.js {}
        format.json { render :show, status: :created, location: @adjustment_type }
      else
        format.html { render :new }
        format.json { render json: @adjustment_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @adjustment_type.update(adjustment_type_params)
        format.html { redirect_to @adjustment_type, notice: 'Adjustment type was successfully updated.' }
        format.js {}
        format.json { render :show, status: :ok, location: @adjustment_type }
      else
        format.html { render :edit }
        format.json { render json: @adjustment_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @adjustment_type.destroy
    respond_to do |format|
      format.html { redirect_to adjustment_types_url, notice: 'Adjustment type was successfully destroyed.' }
      format.js {}
      format.json { head :no_content }
    end
  end

  private
  
  def set_adjustment_type
    @adjustment_type = AdjustmentType.find(params[:id])
  end

  def adjustment_type_params
    params.require(:adjustment_type).permit(:name)
  end
end