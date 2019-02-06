require 'rails_helper'

describe SessionsController do
  context ".new" do
    it "renders the login page" do
      get :new

      expect(response.status).to eq 200
      assert_template :new
    end
  end

  context ".create" do
    context "correct username and password" do
      it "creates a session and returns the user to the article index" do
        user = create(:user)
        params = { session: {
                    username: "Fakeyfakefake",
                    password: "fakepass"
                  } }

        post :create, params: params

        expect(controller.current_user).to eq(user)
        expect(response.status).to eq 302
        expect(response).to redirect_to articles_path
      end
    end

    context "incorrect username or password" do
      it "sends the user back to the login page" do
        user = create(:user)
        params = { session: {
                    username: "Fakeyfakefake",
                    password: "pass"
                  } }

        post :create, params: params

        expect(response.status).to eq 302
        expect(response).to redirect_to login_path
        expect(flash[:alert]).to eq "Incorrect username or password"
      end
    end
  end

  context ".destroy" do
    it "redirects to the login page" do
      delete :destroy

      expect(controller.current_user).to eq(nil)
      expect(response.status).to eq 302
      expect(response).to redirect_to login_path
    end
  end
end
