class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  def index
    @contacts = Contact.all.order("name")
  end

  def create
    @contact = Contact.new(contact_params)

    respond_to do |format|
      if @contact.save
        qbo_rails = QboRails.new(QboConfig.last, :customer)
        qb_customer = qbo_rails.base.qr_model(:customer)
        qb_customer.display_name = @contact.name

        phone = qbo_rails.base.qr_model(:telephone_number)
        phone.free_form_number = @contact.phone_number

        address = qbo_rails.base.qr_model(:physical_address)
        address.line1 = @contact.address
        address.city =  @contact.city
        address.country_sub_division_code = @contact.state
        address.postal_code = @contact.postal_code

        qb_customer.billing_address = address
        qb_customer.primary_phone = phone
        qbo_rails.create_or_update(@contact, qb_customer)

        format.html { redirect_to @contact, flash: { success: 'Contact was successfully created.' } }
        format.js {}
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new }
        format.js {}
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end


  def update
    respond_to do |format|
      if @contact.update(contact_params)
        qbo_rails = QboRails.new(QboConfig.last, :customer)
        qb_customer = qbo_rails.base.qr_model(:customer)
        qb_customer.display_name = @contact.name

        phone = qbo_rails.base.qr_model(:telephone_number)
        phone.free_form_number = @contact.phone_number

        address = qbo_rails.base.qr_model(:physical_address)
        address.line1 = @contact.address
        address.city =  @contact.city
        address.country_sub_division_code = @contact.state
        address.postal_code = @contact.postal_code

        qb_customer.billing_address = address
        qb_customer.primary_phone = phone
        qbo_rails.create_or_update(@contact, qb_customer)

        format.html { redirect_to contacts_path, flash: { success: 'Contact was successfully updated.' } }
        format.js {}
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end  

  def show
    @contact = Contact.find(params[:id])
  end

  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Contact was successfully destroyed.' }
      format.js {}
      format.json { head :no_content }
    end
  end

  def fetch
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, QboConfig.first.token, QboConfig.first.secret)
    customer_service = Quickbooks::Service::Customer.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)
    query = "SELECT * FROM Customer WHERE active = true"
    customer_service.query_in_batches(query, per_page: 1000) do |batch|
      batch.each do |customer|
        customer_name = customer.given_name || customer.display_name
        if Contact.where(name: customer_name).count == 0
          Contact.create!(name: customer_name, qbo_id: customer.id)
        end
      end
    end
    redirect_to contacts_path
  end  

  private

  def contact_params
    params.require(:contact).permit(:name, :address, :city, :state, :postal_code, :country, :email_address, :phone_number, :qbo_id)
  end

  def set_contact
    @contact = Contact.find(params[:id])
  end
end
