require 'rails_helper'

RSpec.describe Sale, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:amount) }
  end

  describe 'associations' do
    it { should belong_to(:sales_receipt) }
  end
end
