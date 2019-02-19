require 'rails_helper'

describe "user profile pages" do
  attr_reader :user, :admin

  before(:each) do
    @user = create(:user)
    @admin = create(:admin)
  end

  context "previous suspensions" do
    attr_reader :suspension
    before(:each) do
      @suspension = Suspension.create(user: user, is_suspended: true)
    end

    context "as an admin" do
      it "displays all previous suspensions for the user" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit user_path(user)

        expect(page).to have_content "User Suspensions"
        expect(page).to have_content suspension.created_at.to_date
      end
    end

    context "unpermitted users" do
      context "visitors, users" do
        it "does not display any previous suspensions" do
          users = [nil, user]

          users.each do |tested_user|
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(tested_user)

            visit user_path(user)

            expect(page).to_not have_content "User Suspensions"
            expect(page).to_not have_content suspension.created_at.to_date
          end
        end
      end
    end
  end

  context "suspend user" do
    context "as an admin" do
      it "has a button to suspend/reactivate the user" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        expect(user.suspended?).to eq false

        visit user_path(user)

        click_button("Suspend User")

        expect(user.suspended?).to eq true

        click_button("Reactivate User")

        expect(user.suspended?).to eq false
      end
    end

    context "as a user" do
      it "does not have the button to suspend the user" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit user_path(user)

        expect(page).to_not have_button "Suspend User"
        expect(page).to_not have_button "Reactivate User"
      end
    end
  end

  context "change user to admin" do
    context "as an admin" do
      it "show the button and allows the admin to change the user" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit user_path(user)

        expect(User.where(role: 1).count).to eq 1

        click_button "Make Admin"

        expect(User.where(role: 1).count).to eq 2

        click_button "Remove Admin"

        expect(User.where(role: 1).count).to eq 1
      end
    end

    context "unpermitted users" do
      context "visitors and users" do
        it "does not show the make admin button" do
          users = [nil, user]

          users.each do |tested_user|
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(tested_user)

            visit user_path(user)
            expect(page).to_not have_button "Make Admin"
            expect(page).to_not have_button "Remove Admin"
          end
        end
      end
    end
  end
end
