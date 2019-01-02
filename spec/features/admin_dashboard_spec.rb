require 'rails_helper'

describe "Admin Dashboard" do
  attr_reader :user, :article, :admin

  before(:each) do
    @user = User.create!(
      first_name: "FakeFirst",
      last_name: "FakeLast",
      username: "Fakeyfakefake",
      password: "fakepass",
      email: "fake@fake.com",
      role: "default"
    )

    @article = Article.create!(
      title: "Fake Title",
      body: "Fake Body",
      user_id: user.id
    )

    @admin = User.create!(
      first_name: "FakeFirst",
      last_name: "FakeLast",
      username: "admin",
      password: "fakepass",
      email: "admin@admin.com",
      role: "admin"
    )
  end

  after(:each) do
    Article.all.each do |article|
      article.delete
    end

    User.all.each do |user|
      user.delete
    end
  end

  describe "access" do
    context "as a user" do
      it "does not allow the user to see the admin dashboard" do
        visit admin_dashboard_path(admin.id)

        expect(page.status_code).to eq 404
      end
    end

    context "as an admin" do
      it "allows the admin to access the admin dashboard" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit admin_dashboard_path(admin.id)

        expect(page.status_code).to eq 200
        expect(page).to have_current_path "/admin/dashboard/#{admin.id}"
      end
    end
  end

  describe "use the search to find a user" do
    it "returns all users containing the search term with a link to their profile" do
      user2 = User.create!(
        first_name: "FakeFirst",
        last_name: "FakeLast",
        username: "fakeusername",
        password: "fakepass",
        email: "totesfake@fake.com",
        role: "default"
      )

      user3 = User.create!(
        first_name: "FakeFirst",
        last_name: "FakeLast",
        username: "shouldnotreturn",
        password: "fakepass",
        email: "notatallfake@fake.com",
        role: "default"
      )

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

      visit admin_dashboard_path(admin.id)

      fill_in "user_search", with: "fake"
      click_button "Find User"

      expect(page).to have_link user.username
      expect(page).to have_link user2.username
      expect(page).to_not have_link user3.username

      click_on user.username
      expect(page).to have_current_path "/users/#{user.id}"
    end
  end
end