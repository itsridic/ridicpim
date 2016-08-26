class Account < ApplicationRecord
	RESTRICTED_SUBDOMAINS = %w(www)

	belongs_to :owner, class_name: 'User'
	validates :owner, presence: true

	validates :subdomain, presence: true,
												uniqueness: { case_sensitive: false },
												format: { with: /\A[\w\-]+\Z/i, message: 'contains invalid characters' },
												exclusion: { in: RESTRICTED_SUBDOMAINS, message: 'restricted' }

	accepts_nested_attributes_for :owner
	before_validation :downcase_subdomain
	has_settings :sales_receipt_default_customer, :sales_receipt_deposit_to_account

	private

	def downcase_subdomain
		self.subdomain = subdomain.try(:downcase)
	end												
end
