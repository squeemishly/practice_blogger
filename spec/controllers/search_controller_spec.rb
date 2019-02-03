require 'rails_helper'

describe SearchController do
  context ".show" do
    context "there is text in the search field" do
      it "returns the user's articles" do
        article = create(:article)
        get :show, params: {
                    id: 1,
                    article_search: "Fake"
                  }

        expect(response.status).to eq 200
        assert_template :show
      end
    end

    context "the search field is empty" do
      it "redirects to the page the user is already on" do
        request.env['HTTP_REFERER'] = articles_path
        get :show, params: {
                    id: 1,
                    article_search: ""
                  }

        expect(response).to redirect_to articles_path
      end
    end
  end
end
