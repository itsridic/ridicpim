module TransferHelper
  def from_location(transfer)
    location = Location.find(transfer.from_location_id)
    location.name
  end

  def to_location(transfer)
    location = Location.find(transfer.to_location_id)
    location.name
  end
end