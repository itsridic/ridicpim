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
    @product = Product.new
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

  def fetch
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, QboConfig.first.token, QboConfig.first.secret)
    product_service = Quickbooks::Service::Item.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)
    query = "SELECT * FROM Item WHERE active = true AND type = 'NonInventory'"
    product_service.query_in_batches(query, per_page: 1000) do |batch|
      batch.each do |product|
        product_sku   = product.sku
        product_name  = product.name || product.description
        product_price = product.unit_price || 0
        product_sku = product_name if product_sku.blank?
        if Product.where(amazon_sku: product_sku).count == 0
          Product.create!(name: product_name, amazon_sku: product_sku, price: product_price, qbo_id: product.id)
        end
      end
    end
    redirect_to products_path
  end

  private

  def product_params
    params.require(:product).permit(:name, :amazon_sku, :price, :bundle_quantity, :bundle_product_id)
  end

  def set_product
    @product = Product.find(params[:id])
  end
end
