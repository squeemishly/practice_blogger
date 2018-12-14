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

  context "methods" do
    context ".authenticate" do
      attr_reader :user

      before(:each) do
        @user = User.create(
          first_name: :fake_first_name,
          last_name: :fake_last_name,
          email: :fake_email,
          password: :fake_pass,
          username: :fake_username
        )
      end

      it "returns the user when username and password are correct" do
        expect(user.authenticate(user.username, user.password)).to eq user
      end

      it "returns nil with an incorrect password" do
        expect(user.authenticate(user.username, :diff_pass)).to be_nil
      end

      it "returns nil with an incorrect username" do
        expect(user.authenticate(:diff_user, user.password)).to be_nil
      end
    end
  end
end
