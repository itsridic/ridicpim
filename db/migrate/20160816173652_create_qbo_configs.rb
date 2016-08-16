class CreateQboConfigs < ActiveRecord::Migration[5.0]
  def change
    create_table :qbo_configs do |t|
      t.string :token
      t.string :secret
      t.string :realm_id

      t.timestamps
    end
  end
end
