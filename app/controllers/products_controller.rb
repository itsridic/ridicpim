class ProductsController < ApplicationController
  respond_to :json, only: [:create, :edit, :update, :destroy]

  def index
    load_products
    build_product
  end

  def edit
    load_product
  end

  def show
    load_product
  end

  def create
    build_product
    save_product
  end

  def update
    load_product
    build_product
    save_product
  end

  def destroy
    load_product
    @product.destroy
  end

  def fetch
    product_service = QuickbooksServiceFactory.new.item_service
    query = "SELECT * FROM Item WHERE active = true AND type = 'NonInventory'"
    product_service.query_in_batches(query, per_page: 1000) do |batch|
      create_products_from_batch(batch)
    end
    redirect_to products_path
  end

  private

  def product_params
    product_params = params[:product]
    if product_params
      product_params.permit(:name, :amazon_sku, :price, :qbo_id,
                            :bundle_quantity, :bundle_product_id)
    else
      {}
    end
  end

  def load_products
    @products ||= product_scope
  end

  def load_product
    @product ||= product_scope.find(params[:id])
  end

  def product_scope
    Product.all
  end

  def build_product
    @product ||= product_scope.build
    @product.attributes = product_params
  end

  def save_product
    render action: 'failure' unless @product.save
    create_update_product_in_qbo(@product) if QboConfig.exists?
  end

  def create_update_product_in_qbo(product)
    qbo_rails = QboRails.new(QboConfig.last, :item)
    item = qbo_rails.base.qr_model(:item)
    item.income_account_id =
      current_account.settings(:sales_receipt_income_account).val
    item.type = 'NonInventory'
    item.name = product.name
    item.description = product.name
    item.unit_price = product.price
    item.sku = product.amazon_sku
    qbo_rails.create_or_update(product, item)
  end

  def create_product(product_name, product_sku, product_price, id)
    Product.create!(name: product_name, amazon_sku: product_sku,
                    price: product_price, qbo_id: id)
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
    details[:product_sku] = product.sku
    details[:product_name] = product.name || product.description
    details[:product_price] = product.unit_price || 0
    if details[:product_sku].blank?
      details[:product_sku] = details[:product_name]
    end
    details
  end
end
