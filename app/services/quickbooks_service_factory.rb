class QuickbooksServiceFactory
  attr_reader :oauth_client
  def initialize
    @oauth_client = OAuth::AccessToken.new(
      $qb_oauth_consumer,
      QboConfig.first.token,
      QboConfig.first.secret
    )
  end

  def account_service
    Quickbooks::Service::Account.new(
      access_token: oauth_client,
      company_id: QboConfig.realm_id
    )
  end

  def item_service
    Quickbooks::Service::Item.new(
      access_token: oauth_client,
      company_id: QboConfig.realm_id
    )
  end

  def customer_service
    Quickbooks::Service::Customer.new(
      access_token: oauth_client,
      company_id: QboConfig.realm_id
    )
  end
end
