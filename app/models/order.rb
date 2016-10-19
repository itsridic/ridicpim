class Order < ApplicationRecord
  belongs_to :contact
  belongs_to :location
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true
  after_save :set_user_date

  validates :name, presence: true
  validates :contact, presence: true
  validates :location, presence: true

  private

  def set_user_date
    if user_date.blank?
      self.update_column(:user_date, self.created_at)
    end
  end
end
