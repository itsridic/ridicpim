class CreateCredentials < ActiveRecord::Migration[5.0]
  def change
    create_table :credentials do |t|
      t.string :primary_marketplace_id
      t.string :merchant_id
      t.string :auth_token

      t.timestamps
    end
  end
end
