class ContactsController < ApplicationController
  respond_to :json, only: [:create, :edit, :update, :destroy]

  def index
    load_contacts
  end

  def create
    build_contact
    save_contact
  end

  def edit
    load_contact
  end

  def update
    load_contact
    build_contact
    save_contact
  end

  def show
    load_contact
  end

  def destroy
    load_contact
    @contact.destroy
  end

  QBO_QUERY = 'SELECT * FROM Customer WHERE active = true'.freeze
  def fetch
    customer_service = QuickbooksServiceFactory.new.customer_service
    customer_service.query_in_batches(QBO_QUERY, per_page: 1000) do |batch|
      batch.each do |customer|
        customer_name = customer.given_name || customer.display_name
        if Contact.where(name: customer_name).count.zero?
          Contact.create!(name: customer_name, qbo_id: customer.id)
        end
      end
    end
    redirect_to contacts_path
  end

  private

  def contact_params
    contact_params = params.require(:contact)
    if contact_params
      contact_params.permit(:name, :address, :city, :state, :postal_code,
                            :country, :email_address, :phone_number, :qbo_id)
    else
      {}
    end
  end

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def build_contact
    @contact ||= contact_scope.build
    @contact.attributes = contact_params
  end

  def load_contacts
    @contacts ||= contact_scope
  end

  def load_contact
    @contact ||= contact_scope.find(params[:id])
  end

  def save_contact
    render action: 'failure' unless @contact.save
    create_update_contact_in_qbo(@contact)
  end

  def create_update_contact_in_qbo(contact)
    qbo_rails = QboRails.new(QboConfig.last, :customer)
    qb_customer = qbo_rails.base.qr_model(:customer)
    qb_customer.display_name = contact.name

    phone = qbo_rails.base.qr_model(:telephone_number)
    phone.free_form_number = contact.phone_number

    address = qbo_rails.base.qr_model(:physical_address)
    address.line1 = contact.address
    address.city =  contact.city
    address.country_sub_division_code = contact.state
    address.postal_code = contact.postal_code

    qb_customer.billing_address = address
    qb_customer.primary_phone = phone
    qbo_rails.create_or_update(contact, qb_customer)
  end

  def contact_scope
    Contact.all
  end
end
