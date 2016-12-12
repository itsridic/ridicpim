class Contact < ApplicationRecord
  has_many :orders
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :name, presence: true
  validates :email_address, length: { maximum: 255 },
                          format: { with: VALID_EMAIL_REGEX },
                          allow_blank: true
  default_scope -> { order("name") }
end
