class CreateCancellations < ActiveRecord::Migration[5.0]
  def change
    create_table :cancellations do |t|
      t.references :account, foreign_key: true
      t.references :user, foreign_key: true
      t.text :reason

      t.timestamps
    end
  end
end
