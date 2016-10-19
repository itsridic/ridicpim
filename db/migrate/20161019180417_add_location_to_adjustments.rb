class AddLocationToAdjustments < ActiveRecord::Migration[5.0]
  def change
    add_reference :adjustments, :location, foreign_key: true
  end
end
