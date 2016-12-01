class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :tos]
  skip_before_action :check_active_status
  #skip_before_action :set_quickbooks_base_config

  def index
  end

  def tos
    render layout: false
  end
end
