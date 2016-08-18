require 'rails_helper'

RSpec.describe Adjustment, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:product) }
    it { should validate_presence_of(:adjustment_type) }
    it { should validate_presence_of(:adjusted_quantity) }
  end

  describe 'associations' do
    it { should belong_to(:product) }
    it { should belong_to(:adjustment_type) }
  end
end
