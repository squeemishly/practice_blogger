require 'rails_helper'

describe SuspensionsController do
  attr_reader :user, :admin

  before(:each) do
    @user = create(:user)
    @admin = create(:admin)
  end

  context ".create" do
    context "as an admin" do
      it "creates the user suspension and redirects to the user" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        expect {
          post :create, params: { user: user.id }
        }.to change(Suspension, :count).by 1

        expect(response.status).to eq 302
        expect(response).to redirect_to user_path(user)
      end
    end

    context "as a user" do
      it "returns a 403" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        post :create, params: { user: user.id }

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end
  end

  context ".update" do
    context "as an admin" do
      it "updates the suspension to false and shows the user" do
        user.suspensions.create(user: user, is_suspended: true)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        put :update, params: { id: 1, user: user.id }

        expect(user.suspended?).to eq false
        expect(response.status).to eq 302
        expect(response).to redirect_to user_path(user)
      end
    end

    context "as a user" do
      it "returns a 403" do
        user.suspensions.create(user: user, is_suspended: true)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        put :update, params: { id: 1, user: user.id }

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end
  end
end
