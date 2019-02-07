require 'rails_helper'

describe "user profile pages" do
  context "suspend user" do
    context "as an admin" do
      it "has a button to suspend/reactivate the user" do
        user = create(:user)
        admin = create(:admin)

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
        user = create(:user)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit user_path(user)

        expect(page).to_not have_button "Suspend User"
        expect(page).to_not have_button "Reactivate User"
      end
    end
  end
end
