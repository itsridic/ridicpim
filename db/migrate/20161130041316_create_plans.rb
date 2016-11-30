class CreatePlans < ActiveRecord::Migration[5.0]
  def change
    create_table :plans do |t|
      t.integer :stripe_id
      t.string :name
      t.integer :price
      t.integer :trial_period_days

      t.timestamps
    end
  end
end
