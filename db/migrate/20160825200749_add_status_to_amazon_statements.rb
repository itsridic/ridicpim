class AddStatusToAmazonStatements < ActiveRecord::Migration[5.0]
  def change
    add_column :amazon_statements, :status, :string
  end
end
