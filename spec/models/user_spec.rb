require 'rails_helper'

RSpec.describe User, type: :model do
  attr_reader :user

  before(:each) do
    @user = User.create!(
      first_name: "FakeFirst",
      last_name: "FakeLast",
      username: "Fakeyfakefake",
      password: "fakepass",
      email: "fake@fake.com",
      role: "default"
    )
  end

  after(:each) do
    User.all.each do |user|
      user.destroy
    end
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
end
