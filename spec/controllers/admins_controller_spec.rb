require 'rails_helper'

describe AdminsController do
  attr_reader :user, :admin

  before(:each) do
    @user = create(:user)
    @admin = create(:admin)
  end

  describe ".new" do
    context "current user is admin" do

    end

    context "unpermitted users" do
      context "visitors, users" do
        it "returns a 403" do
          users = [nil, user]

          users.each do |tested_user|
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(tested_user)

            params = { user_id: user.id }

            get :new, params: params

            expect(response.status).to eq 403
          end
        end
      end
    end
  end

  describe ".destroy" do

  end
end
