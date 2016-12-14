class AdjustmentTypesController < ApplicationController
  respond_to :json, only: [:create, :edit, :update, :destroy]

  def index
    load_adjustment_types
    build_adjustment_type
  end

  def show
    load_adjustment_type
  end

  def new
    build_adjustment_type
  end

  def edit
    load_adjustment_type
  end

  def create
    build_adjustment_type
    save_adjustment_type
  end

  def update
    load_adjustment_type
    build_adjustment_type
    save_adjustment_type
  end

  def destroy
    load_adjustment_type
    @adjustment_type.destroy
  end

  private

  def adjustment_type_params
    adjustment_type_params = params[:adjustment_type]
    if adjustment_type_params
      adjustment_type_params.permit(:name)
    else
      {}
    end
  end

  def load_adjustment_types
    @adjustment_types ||= adjustment_type_scope
  end

  def load_adjustment_type
    @adjustment_type ||= adjustment_type_scope.find(params[:id])
  end

  def build_adjustment_type
    @adjustment_type ||= adjustment_type_scope.build
    @adjustment_type.attributes = adjustment_type_params
  end

  def save_adjustment_type
    render action: 'failure' unless @adjustment_type.save
  end

  def adjustment_type_scope
    AdjustmentType.all
  end
end
