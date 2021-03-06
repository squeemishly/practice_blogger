require 'rails_helper'

describe "Admin Dashboard" do
  attr_reader :user, :article, :admin

  before(:each) do
    @user = create(:user)
    @article = create(:article, user: user)
    @admin = create(:admin)
  end

  describe "access" do
    context "a user" do
      it "is not allowed to see the admin dashboard" do
        users = [nil, user]

        users.each do |tested_user|
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(tested_user)

          visit admin_dashboard_path(admin)

          expect(page.status_code).to eq 403
          expect(page).to have_content "You are not authorized to enter this area."

          visit admin_dashboard_path(user)

          expect(page.status_code).to eq 403
          expect(page).to have_content "You are not authorized to enter this area."
        end
      end
    end

    context "an admin" do
      it "is allowed to access the admin dashboard" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit admin_dashboard_path(admin)

        expect(page.status_code).to eq 200
        expect(page).to have_current_path admin_dashboard_path(admin)
      end
    end
  end

  describe "use the search to find a user" do
    it "returns all users containing the search term with a link to their profile" do
      user2 = create(:rando_user, username: "anotherfake")
      user3 = create(:diff_user)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

      visit admin_dashboard_path(admin)

      fill_in "user_search", with: "fake"
      click_button "Find User"

      expect(page).to have_link(user.username, href: user_path(user))
      expect(page).to have_link(user2.username, href: user_path(user2))
      expect(page).to_not have_link user3.username
    end
  end

  describe "recent activity" do
    describe "recent articles" do
      attr_reader :user2, :article2

      before(:each) do
        @user2 = create(:rando_user)
        @article2 = create(:article, title: "second article", user: user2)
      end

      it "displays the most recent articles in descending order" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit admin_dashboard_path(admin)

        expect(page).to have_content "#{article2.title} by #{user2.username} #{article.title} by #{user.username}"
      end

      context "suspended users" do
        it "does not display the articles of suspended users" do
          Suspension.create(user: user, is_suspended: true)
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

          visit admin_dashboard_path(admin)

          expect(page).to have_content "#{article2.title} by #{user2.username}"
          expect(page).to_not have_content "#{article.title} by #{user.username}"
        end
      end
    end
  end

  context "suspended users button" do
    it "has a button to show all user suspensions" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
      visit admin_dashboard_path(admin)

      expect(page).to have_button "View Suspended Users"
    end
  end
end
