require 'rails_helper'

describe "Nav Bars" do
  context "Links" do
    context "a visitor" do
      it "contains home, login, and create account links" do
        visit root_path

        expect(page).to have_link("Return Home", href: root_path)
        expect(page).to have_link("Login", href: login_path)
        expect(page).to have_link("Create an Account", href: new_user_path)
      end
    end

    context "a logged in user" do
      it "has home, write post, profile, and logout links" do
        user = User.create!(
          first_name: "FakeFirst",
          last_name: "FakeLast",
          username: "Fakeyfakefake",
          password: "fakepass",
          email: "fake@fake.com",
          role: "default"
        )

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit root_path

        expect(page).to have_link("Return Home", href: root_path)
        expect(page).to have_link("Write New Blog Post", href: new_article_path)
        expect(page).to have_link("#{user.username} profile", href: user_path(user))
        expect(page).to have_link("Logout", href: logout_path)
      end
    end

    context "an admin" do
      it "has home, dashboard, write post, profile, and logout links" do
        admin = User.create!(
          first_name: "FakeFirst",
          last_name: "FakeLast",
          username: "Fakeyfakefake",
          password: "fakepass",
          email: "fake@fake.com",
          role: "admin"
        )

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit root_path

        expect(page).to have_link("Return Home", href: root_path)
        expect(page).to have_link("Dashboard", href: admin_dashboard_path(admin))
        expect(page).to have_link("Write New Blog Post", href: new_article_path)
        expect(page).to have_link("#{admin.username} profile", href: user_path(admin))
        expect(page).to have_link("Logout", href: logout_path)
      end
    end
  end

  context "User Search" do
    it "returns articles by the user you search for" do
      user = User.create!(
        first_name: "FakeFirst",
        last_name: "FakeLast",
        username: "Fakeyfakefake",
        password: "fakepass",
        email: "fake@fake.com",
        role: "default"
      )

      rando_user = User.create!(
        first_name: "FakeFirst",
        last_name: "FakeLast",
        username: "randouser",
        password: "randopass",
        email: "rando@rando.com",
        role: "default"
      )

      article = Article.create!(
        title: "Fake Title",
        body: "Fake Body",
        user: user
      )

      rando_article = Article.create!(
        title: "totes post",
        body: "Fake Body",
        user: rando_user
      )

      visit root_path

      fill_in "article_search", with: "fake"
      click_button "Search"

      expect(page).to have_link(article.title, href: article_path(article))
      expect(page).to have_content user.username
      expect(page).to_not have_link rando_article.title
      expect(page).to_not have_content rando_user.username
    end
  end
end
