class AmazonStatement < ApplicationRecord
  default_scope -> { order('period DESC') }
  scope :settlement_exists, ->(si) { where(settlement_id: si) }
end
