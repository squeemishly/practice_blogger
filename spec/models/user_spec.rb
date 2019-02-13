require 'rails_helper'

RSpec.describe User, type: :model do
  attr_reader :user

  before(:each) do
    @user = create(:user)
  end

  context "attributes" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_presence_of(:username) }
  end

  context "relationships" do
    it { should have_many(:articles) }
    it { should have_many(:suspensions) }

    context "user avatar" do
      it "should have one avatar attached" do
        user.avatar.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'default_avatar.png')), filename: "default_avatar.png")

        expect(user.avatar).to be_an_instance_of(ActiveStorage::Attached::One)
      end
    end
  end

  context "user roles" do
    it "is default when created" do
      expect(User.new.role).to eq "default"
    end

    it "can be upgraded to admin" do
      user.role = "admin"

      expect(user.role).to eq "admin"
    end
  end

  context "methods" do
    context ".suspended?" do
      it "returns true when a user is suspended" do
        user.suspensions.create(user: user, is_suspended: true)

        expect(user.suspended?).to be true
      end

      it "returns false when a user is not suspended" do
        expect(user.suspended?).to be false
      end
    end

    context ".is_admin?" do
      it "returns true when a user is an admin" do
        user.role = "admin"

        expect(user.is_admin?).to eq true
      end

      it "returns false when a user is not an admin" do
        expect(user.is_admin?).to eq false
      end
    end
  end
end
