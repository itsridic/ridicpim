class CredentialsController < ApplicationController
  respond_to :json, only: [:create, :edit, :update, :destroy]

  def index
    load_credentials
    build_credential
  end

  def show
    load_credential
  end

  def edit
    load_credential
  end

  def create
    build_credential
    destroy_old_credentials
    save_credential
  end

  def update
    load_credential
    build_credential
    save_credential
  end

  def destroy
    load_credential
    @credential.destroy
  end

  private

  def credential_params
    credential_params = params[:credential]
    if credential_params
      credential_params.permit(:primary_marketplace_id, :auth_token,
                               :merchant_id)
    else
      {}
    end
  end

  def build_credential
    @credential ||= credential_scope.build
    @credential.attributes = credential_params
  end

  def load_credentials
    @credentials ||= credential_scope
  end

  def load_credential
    @credential ||= credential_scope.find(params[:id])
  end

  def save_credential
    render action: 'failure' unless @credential.save
  end

  def credential_scope
    Credential.all
  end

  def destroy_old_credentials
    credential_scope.destroy_all unless credential_scope.count.zero?
  end
end
