require 'csv'

class ProductsFromAmazonWorker
	include Sidekiq::Worker

	def perform(current_account_id)
    puts "current_account_id = #{current_account_id}"
    current_account = Account.find(current_account_id)
		client = get_client
		requested_report = client.request_report("_GET_FLAT_FILE_OPEN_LISTINGS_DATA_").parse
		report_request_id = requested_report["ReportRequestInfo"]["ReportRequestId"]
		get_product_report_from_amazon(report_request_id, client, current_account)
	end

	def get_client
		client = MWS::Reports::Client.new(
			primary_marketplace_id: Credential.last.primary_marketplace_id,
			merchant_id: Credential.last.merchant_id,
			aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
			aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
			auth_token: Credential.last.auth_token
		)
	end

	def get_product_report_from_amazon(report_request_id, client, current_account, status="")
		while status != "_DONE_"
			resp = client.get_report_request_list(report_request_id_list: [report_request_id]).parse
      puts "response = #{resp}"
			status = resp["ReportRequestInfo"]["ReportProcessingStatus"]
			if status == "_DONE_"
				report_id = resp["ReportRequestInfo"]["GeneratedReportId"]
				product_csv = client.get_report(report_id).parse
				parse_product_report(product_csv, current_account)
			end
			sleep 30
		end
	end

	def parse_product_report(product_csv, current_account)
		product_csv.each do |product|
      if Product.where("amazon_sku = ?", product["sku"]).count.zero?
        prod = Product.create!(name: product["sku"], amazon_sku: product["sku"], price: product["price"])
        qbo_rails = QboRails.new(QboConfig.last, :item)
        item = qbo_rails.base.qr_model(:item)
        item.income_account_id =
          current_account.settings(:sales_receipt_income_account).val
        item.type = 'NonInventory'
        item.name = prod.name
        item.description = prod.name
        item.unit_price = prod.price
        item.sku = prod.amazon_sku
        qbo_rails.create_or_update(prod, item)
      end
    end
  end
end

