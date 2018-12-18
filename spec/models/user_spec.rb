require 'rails_helper'

RSpec.describe User, type: :model do
  context "attributes" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_presence_of(:username) }
  end

  context "relationships" do
    it { should have_many(:articles) }
  end

  context "user roles" do
    it "has a default and admin role" do
      user_roles = ["default", "admin"]

      user_roles.each_with_index do |role, index|
        expect(role).to eq user_roles[index]
      end
    end
  end
end
