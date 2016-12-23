class RemoveDescriptionFromTransferItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :transfer_items, :description
  end
end
