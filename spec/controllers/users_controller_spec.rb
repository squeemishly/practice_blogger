require 'rails_helper'

describe UsersController do
  attr_reader :user, :admin, :rando_user

  before(:each) do
    @user = create(:user)
    @admin = create(:admin)
    @rando_user = create(:rando_user)
  end

  context ".new" do
    it "renders the new user template" do
      get :new

      expect(response.status).to eq 200
      assert_template :new
    end
  end

  context ".create" do
    context "all of the fields are filled in" do
      it "creates the user and redirects to the articles path" do
        params = { user: {
                  first_name: :fake_first_name,
                  last_name: :fake_last_name,
                  username: :fake_username,
                  password: :fake_pass,
                  email: :fake_email
                } }

        expect {
          post :create, params: params
              }.to change(User, :count).by 1

        expect(response.status).to eq 302
        expect(response).to redirect_to articles_path
      end
    end

    context "the user missed a field" do
      it "sends an alert and renders the new page again" do
        params = { user: {
                  first_name: :fake_first_name,
                  last_name: :fake_last_name,
                  username: :fake_username,
                  password: :fake_pass
                } }

        expect {
          post :create, params: params
              }.to change(User, :count).by 0

        expect(response.status).to eq 200
        assert_template :new
      end
    end
  end

  context ".show" do
    it "renders the show page" do
      get :show, params: { id: user.id }

      expect(response.status).to eq 200
      assert_template :show
    end
  end

  context ".edit" do
    context "permitted editors" do
      context "a user on their own profile or an admin" do
        it "renders the edit page" do
          users = [user, admin]

          users.each do |tested_user|
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(tested_user)
            get :edit, params: { id: user.id }

            expect(response.status).to eq 200
            assert_template :edit
          end
        end
      end
    end

    context "unpermitted editors" do
      context "a visitor or a random user" do
        it "returns a 403" do
          users = [nil, rando_user]

          users.each do |tested_user|
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(tested_user)
            get :edit, params: { id: user.id }

            expect(response.status).to eq 403
            expect(response).to render_template(file: "#{Rails.root}/public/403.html")
          end
        end
      end
    end
  end

  context ".update" do
    attr_reader :params

    before(:each) do
      @params = { id: user.id,
                  user: {
                    first_name: "new first name",
                    last_name: "last_name",
                    username: "username",
                    password: "pass",
                    email: "email"
                  } }
    end

    context "permitted updaters" do
      context "a user on their own profile or an admin" do
        it "updates and renders the user show page" do
          users = [user, admin]

          users.each do |tested_user|
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(tested_user)
            get :update, params: params

            expect(response.status).to eq 302
            expect(response).to redirect_to user_path(user)
          end
        end
      end
    end

    context "unpermitted updaters" do
      context "a visitor or a random user" do
        it "returns a 403" do
          users = [nil, rando_user]

          users.each do |tested_user|
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(tested_user)
            get :update, params: params

            expect(response.status).to eq 403
            expect(response).to render_template(file: "#{Rails.root}/public/403.html")
          end
        end
      end
    end
  end
end
