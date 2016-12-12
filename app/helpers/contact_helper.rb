module ContactHelper
  def contact_address(contact)
    if contact.address.blank? && contact.city.blank? && contact.postal_code.blank? && contact.country.blank?
      return ""
    else
      return "#{contact.address} #{contact.city}, #{contact.state}  #{contact.postal_code} #{contact.country}"
    end
  end
end
