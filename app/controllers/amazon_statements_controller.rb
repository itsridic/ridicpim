class AmazonStatementsController < ApplicationController
  def fetch
  end

  private

  def set_qb_service
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, QboConfig.first.token, QboConfig.first.secret)
  end  
end
