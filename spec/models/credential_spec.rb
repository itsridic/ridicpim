require 'rails_helper'

RSpec.describe Credential, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:merchant_id) }
    it { should validate_presence_of(:primary_marketplace_id) }
    it { should validate_presence_of(:auth_token) }
  end
end
