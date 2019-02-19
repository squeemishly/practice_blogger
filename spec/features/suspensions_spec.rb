require 'rails_helper'

describe "User Suspensions Page" do
  attr_reader :user, :admin, :suspension, :rando_user

  before(:each) do
    @user = create(:user)
    @admin = create(:admin)
    @suspension = Suspension.create(user: user, is_suspended: true)
    @rando_user = create(:rando_user)
  end

  describe "access" do
    context "as an admin" do
      it "renders the suspended users index" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit suspensions_path

        expect(page.status_code).to eq 200
        expect(page).to have_current_path suspensions_path
      end
    end

    context "unpermitted users" do
      context "visitors, users" do
        it "returns a 403" do
          users = [nil, user]

          users.each do |tested_user|
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(tested_user)

            visit suspensions_path

            expect(page.status_code).to eq 403
            expect(page).to have_content "You are not authorized to enter this area."
          end
        end
      end
    end
  end

  describe "content" do
    it "displays currently suspended users" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

      visit suspensions_path

      expect(page).to have_css("h3", text: "Currently Suspended Users:")
      expect(page).to have_link user.username
      expect(page).to have_content suspension.created_at.to_date
      expect(page).to_not have_content rando_user.username
    end

    it "displays all users who have ever been suspended" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

      visit suspensions_path

      expect(page).to have_css("h3", text: "All previously Suspended Users")
      expect(page).to have_link user.username
      expect(page).to have_content suspension.created_at.to_date
      expect(page).to have_content "Suspended 1 time(s)"
      expect(page).to_not have_content rando_user.username
    end
  end
end
