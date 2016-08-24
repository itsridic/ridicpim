module ContactHelper
  def contact_address(contact)
    "#{contact.address} #{contact.city}, #{contact.state}  #{contact.postal_code} #{contact.country}"
  end
end