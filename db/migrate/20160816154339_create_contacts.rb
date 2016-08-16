class CreateContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :address
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country
      t.string :email_address
      t.string :phone_number
      t.integer :qbo_id

      t.timestamps
    end
  end
end
