class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    respond_to do |format|
      if @product.save
        create_update_product_in_qbo(@product) if QboConfig.exists?
        format.js {}
      end
    end
  end

  def index
    @products = Product.all.order('name')
    @product = Product.new
  end

  def show() end

  def update
    respond_to do |format|
      if @product.update(product_params)
        create_update_product_in_qbo(@product) if QboConfig.exists?
        format.js {}
      end
    end
  end

  def destroy
    @product.destroy
    respond_to do |format|
      format.js {}
    end
  end

  def fetch
    product_service = create_product_service
    query = "SELECT * FROM Item WHERE active = true AND type = 'NonInventory'"
    product_service.query_in_batches(query, per_page: 1000) do |batch|
      create_products_from_batch(batch)
    end
    redirect_to products_path
  end

  private

  def product_params
    params.require(:product).permit(:name, :amazon_sku, :price, :qbo_id,
                                    :bundle_quantity, :bundle_product_id)
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def create_update_product_in_qbo(product)
    qbo_rails = QboRails.new(QboConfig.last, :item)
    item = qbo_rails.base.qr_model(:item)
    item.income_account_id =
      current_account.settings(:sales_receipt_income_account).val
    item.type = 'NonInventory'
    item.name = product.amazon_sku
    item.description = product.name
    item.unit_price = product.price
    item.sku = product.amazon_sku
    qbo_rails.create_or_update(product, item)
  end

  def set_oauth_client
    OAuth::AccessToken.new(
      $qb_oauth_consumer, QboConfig.first.token,
      QboConfig.first.secret
    )
  end

  def create_product_service
    oauth_client = set_oauth_client
    Quickbooks::Service::Item.new(
      access_token:  oauth_client,
      company_id: QboConfig.realm_id
    )
  end

  def create_product(product_name, product_sku, product_price, id)
    Product.create!(name: product_name,
                    amazon_sku: product_sku,
                    price: product_price,
                    qbo_id: id)
  end

  def update_product(product_sku, product_id)
    pr = Product.find_by_amazon_sku(product_sku)
    pr.update(qbo_id: product_id) if pr
  end

  def create_products_from_batch(batch)
    batch.each do |product|
      details = product_details(product)
      if Product.find_by_amazon_sku(details[:product_sku]).count.zero?
        create_product(details[:product_name], details[:product_sku],
                       details[:product_price], product.id)
      else
        update_product(details[:product_sku], product.id)
      end
    end
  end

  def product_details(product)
    details = {}
    details[:product_sku] = product.name
    details[:product_name] = product.name || product.description
    details[:product_price] = product.unit_price || 0
    if details[:product_sku].blank?
      details[:product_sku] = details[:product_name]
    end
    details
  end
end
