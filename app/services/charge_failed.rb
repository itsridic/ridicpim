class ChargeFailed
  def call(event)
    account = Account.find_by(sub_token: event.data.object.id)
    account.active = false
    account.save
  end
end
