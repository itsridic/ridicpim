class RemoveLocationsFromTransferItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :transfer_items, :from_location
    remove_column :transfer_items, :to_location
  end
end
