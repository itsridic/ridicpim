class ProductsController < ApplicationController
   before_action :set_product, only: [:show, :edit, :update, :destroy]

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, flash: { success: 'Product was successfully created.' } }
        format.js {}
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def index
    @products = Product.all.order("name")
  end

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to products_path, flash: { success: 'Product was successfully updated.' } }
        format.js {}
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.js {}
      format.json { head :no_content }
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :amazon_sku, :price)
  end

  def set_product
    @product = Product.find(params[:id])
  end
end