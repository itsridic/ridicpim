class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  #skip_before_action :set_quickbooks_base_config
  
	def index
	end
end