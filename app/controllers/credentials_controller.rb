class CredentialsController < ApplicationController
  before_action :set_credential, only: [:show, :edit, :update, :destroy]

  def index
    @credentials = Credential.all
  end

  def show
  end

  def new
    @credential = Credential.new
  end

  def edit
  end

  def create
    @credential = Credential.new(credential_params)
    # Only one set of credentials should exist
    if Credential.count > 0
      Credential.destroy_all
    end
    respond_to do |format|
      if @credential.save
        format.html { redirect_to @credential, notice: 'Credential was successfully created.' }
        format.js {}
        format.json { render :show, status: :created, location: @credential }
      else
        format.html { render :new }
        format.json { render json: @credential.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @credential.update(credential_params)
        format.html { redirect_to @credential, notice: 'Credential was successfully updated.' }
        format.js {}
        format.json { render :show, status: :ok, location: @credential }
      else
        format.html { render :edit }
        format.json { render json: @credential.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @credential.destroy
    respond_to do |format|
      format.html { redirect_to credentials_url, notice: 'Credential was successfully destroyed.' }
      format.js {}
      format.json { head :no_content }
    end
  end

  private

  def set_credential
    @credential = Credential.find(params[:id])
  end

  def credential_params
    params.require(:credential).permit(:primary_marketplace_id, :merchant_id, :auth_token)
  end
end