class AddTriggerUpdateToOrderItems < ActiveRecord::Migration[5.0]
  def change
    add_column :order_items, :trigger_update, :boolean
  end
end
