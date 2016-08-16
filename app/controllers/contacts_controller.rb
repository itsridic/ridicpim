class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  def index
    @contacts = Contact.all.order("name")
  end

  def create
    @contact = Contact.new(contact_params)

    respond_to do |format|
      if @contact.save
        format.html { redirect_to @contact, flash: { success: 'Contact was successfully created.' } }
        format.js {}
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end


  def update
    respond_to do |format|
      if @contact.update(contact_params)
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

  private

  def contact_params
    params.require(:contact).permit(:name, :address, :city, :state, :postal_code, :country, :email_address, :phone_number, :qbo_id)
  end

  def set_contact
    @contact = Contact.find(params[:id])
  end
end
