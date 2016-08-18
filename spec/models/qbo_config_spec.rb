require 'rails_helper'

RSpec.describe QboConfig, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:token) }
    it { should validate_presence_of(:secret) }
    it { should validate_presence_of(:realm_id) }
  end
end
