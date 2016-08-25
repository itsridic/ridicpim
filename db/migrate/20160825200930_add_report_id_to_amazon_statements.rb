class AddReportIdToAmazonStatements < ActiveRecord::Migration[5.0]
  def change
    add_column :amazon_statements, :report_id, :string
  end
end
