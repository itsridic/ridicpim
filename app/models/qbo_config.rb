class QboConfig < ApplicationRecord
  validates :token, presence: true
  validates :secret, presence: true
  validates :realm_id, presence: true
end
