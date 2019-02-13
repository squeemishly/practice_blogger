require 'rails_helper'

describe AdminsController do
  attr_reader :user, :admin

  before(:each) do
    @user = create(:user)
    @admin = create(:admin)
  end

  describe ".new" do
    context "current user is admin" do
      it "allows the admin to upgrade the user to an admin" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        params = { user_id: user.id }

        expect{
          get :new, params: params
        }.to change(User.where(role: 1), :count).by 1
      end
    end

    context "unpermitted users" do
      context "visitors, users" do
        it "returns a 403" do
          users = [nil, user]
          params = { user_id: user.id }

          users.each do |tested_user|
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(tested_user)

            get :new, params: params

            expect(response.status).to eq 403
            expect(response).to render_template(file: "#{Rails.root}/public/403.html")
          end
        end
      end
    end
  end

  describe ".destroy" do
    context "current user is an admin" do
      it "allows the admin to remove admin status from a user" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
        user.update(role: 1)

        params = { id: user.id }

        expect{
          delete :destroy, params: params
        }.to change(User.where(role: 1), :count).by -1
      end
    end

    context "unpermitted users" do
      context "visitors, users" do
        it "returns a 403" do
          users = [nil, user]
          params = { id: user.id }

          users.each do |tested_user|
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(tested_user)

            delete :destroy, params: params

            expect(response.status).to eq 403
            expect(response).to render_template(file: "#{Rails.root}/public/403.html")
          end
        end
      end
    end
  end
end
