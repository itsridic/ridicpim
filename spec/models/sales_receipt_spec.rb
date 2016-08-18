require 'rails_helper'

RSpec.describe SalesReceipt, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:contact) }
    it { should validate_presence_of(:payment) }
  end

  describe 'associations' do
    it { should belong_to(:contact) }
    it { should belong_to(:payment) }
  end
end
