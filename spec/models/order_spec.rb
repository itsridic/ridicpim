require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:contact) }
  end

  describe 'associations' do
    it { should belong_to(:contact) }
  end
end
