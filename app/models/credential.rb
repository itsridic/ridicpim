class Credential < ApplicationRecord
  validates :merchant_id, presence: true
  validates :primary_marketplace_id, presence: true
  validates :auth_token, presence: true
end
