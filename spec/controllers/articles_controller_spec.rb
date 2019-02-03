require 'rails_helper'

describe ArticlesController do
  attr_reader :user, :article, :admin, :rando_user, :comment

  before(:each) do
    @user = create(:user)
    @article = create(:article, user: user)
    @admin = create(:admin)
    @rando_user = create(:rando_user)
    @comment = create(:comment,
                        user: rando_user,
                        article: article)
  end

  context ".index" do
    it "returns a list of articles" do
      allow(Article).to receive(:articles_to_display).and_return([article])
      get :index

      expect(response.status).to eq 200
      assert_template :index
    end
  end

  context ".show" do
    it "returns the article referenced" do
      allow(Article).to receive(:find).and_return(article)
      allow(Comment).to receive(:comments_to_display).and_return([comment])

      get :show, params: { id: article.id }

      expect(response.status).to eq 200
      assert_template :show
    end
  end

  context ".new" do
    context "a logged in user" do
      it "returns a new Article" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        get :new

        expect(response.status).to eq 200
        assert_template :new
      end
    end

    context "a visitor" do
      it "returns a 403" do
        get :new

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end
  end

  context ".create" do
    context "a visitor" do
      it "returns a 403" do
        expect{
           post :create, params: {
                              article: {
                                title: :fake_title,
                                body: :fake_body
                              }
                             }
              }.to change(Article, :count).by 0

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end

    context "a user" do
      context "when all fields are filled in" do
        it "saves the article and redirects to Article show" do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

          expect{
             post :create, params: {
                                article: {
                                  title: :fake_title,
                                  body: :fake_body
                                }
                               }
                }.to change(Article, :count).by 1

          expect(response.status).to eq 302
        end
      end

      context "when a field is missing" do
        it "returns user to new template" do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
          expect{
             post :create, params: {
                                article: {
                                  body: :fake_body
                                }
                               }
                }.to change(Article, :count).by 0

          expect(response.status).to eq 200
          assert_template :new
        end
      end
    end
  end

  context ".edit" do
    context "a visitor is editing the article" do
      it "returns a 403" do
        get :edit, params: { id: article.id }

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end

    context "a user is editing their own article" do
      it "returns the article" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        get :edit, params: { id: article.id }

        expect(response.status).to eq 200
        assert_template :edit
      end
    end

    context "a random user is editing an article" do
      it "returns a 403" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)
        get :edit, params: { id: article.id }

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end

    context "an admin is editing the article" do
      it "returns a 403" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
        get :edit, params: { id: article.id }

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end
  end

  context ".update" do
    context "a visitor" do
      it "returns a 403" do
        put :update, params: {
                              id: article.id,
                              article: {
                                title: :fake_title,
                                body: :fake_body
                              }
                             }

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end

    context "a user is editing their own article" do
      it "updates the article" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        put :update, params: {
                              id: article.id,
                              article: {
                                title: :fake_title,
                                body: :fake_body
                              }
                             }

        expect(response.status).to eq 302
        expect(response).to redirect_to article_path(article)
      end
    end

    context "an admin" do
      it "returns a 403" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)
        put :update, params: {
                              id: article.id,
                              article: {
                                title: :fake_title,
                                body: :fake_body
                              }
                             }

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end

    context "a random user is updating the article" do
      it "returns a 403" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)
        put :update, params: {
                              id: article.id,
                              article: {
                                title: :fake_title,
                                body: :fake_body
                              }
                             }

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end
  end

  context ".destroy" do
    context "a visitor" do
      it "returns a 403" do
        expect{
          delete :destroy, params: { id: article.id }
        }.to change(Article, :count).by 0

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end

    context "an admin" do
      it "deletes the article and redirects to the root path" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
        expect{
          delete :destroy, params: { id: article.id }
        }.to change(Article, :count).by -1

        expect(response.status).to eq 302
        expect(response).to redirect_to articles_path
      end
    end

    context "a user is deleting their own article" do
      it "deletes the article and redirects to the root path" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        expect{
          delete :destroy, params: { id: article.id }
        }.to change(Article, :count).by -1

        expect(response.status).to eq 302
        expect(response).to redirect_to articles_path
      end
    end

    context "a random user is deleting an article they didn't write" do
      it "returns a 403" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)
        expect{
          delete :destroy, params: { id: article.id }
        }.to change(Article, :count).by 0

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end
  end
end
