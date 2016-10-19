class LocationsController < ApplicationController
   before_action :set_location, only: [:show, :edit, :update, :destroy]

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to @location, flash: { success: 'Location was successfully created.' } }
        format.js {}
        format.json { render :show, status: :created, location: @location }
      else
        format.html { render :new }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  def index
    @locations = Location.all.order("name")
  end

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to locations_path, flash: { success: 'Location was successfully updated.' } }
        format.js {}
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @location.destroy
    respond_to do |format|
      format.html { redirect_to locations_url, notice: 'Product was successfully destroyed.' }
      format.js {}
      format.json { head :no_content }
    end
  end

  private

  def location_params
    params.require(:location).permit(:name)
  end

  def set_location
    @location = Location.find(params[:id])
  end
end
