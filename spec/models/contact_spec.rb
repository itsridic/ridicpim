require 'rails_helper'

RSpec.describe Contact, type: :model do
  it { should validate_presence_of(:name) }
  
  it 'should accept valid email addresses' do
    contact = build(:contact, email_address: "nate@itsridic.com")
    expect(contact).to be_valid
  end

  it 'should reject invalid email addresses' do
    contact = build(:contact, email_address: 'nate@example')
    expect(contact).not_to be_valid
  end
end
