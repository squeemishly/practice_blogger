require 'rails_helper'

describe CommentsController do
  attr_reader :article, :user, :comment, :rando_user, :diff_user, :admin

  before(:each) do
    @user = create(:user)
    @article = create(:article, user: user)
    @admin = create(:admin)
    @rando_user = create(:rando_user)
    @comment = create(:comment, user: rando_user, article: article)
    @diff_user = create(:diff_user)
  end

  context ".new" do
    context "a user" do
      it "renders the new page" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        get :new, params: {article_id: article.id}

        expect(response.status).to eq 200
        assert_template :new
      end
    end

    context "a visitor" do
      it "returns a 403" do
        get :new, params: {article_id: article.id}

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end
  end

  context ".create" do
    context "a user" do
      context "all the fields filled in" do
        it "returns the user to the article show" do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
          expect{
             post :create, params: {
                              article_id: article.id,
                              comment: {
                                body: :fake_body
                              }
                            }
                  }.to change(Comment, :count).by 1

          expect(response.status).to eq 302
          expect(response).to redirect_to article_path(article)
        end
      end

      context "a field missing" do
        it "returns the user to the new comment path" do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
          expect{
             post :create, params: {
                              article_id: article.id,
                              comment: {
                                body: ""
                              }
                            }
                  }.to change(Comment, :count).by 0

          expect(response.status).to eq 302
          expect(response).to redirect_to new_article_comment_path(article)
        end
      end
    end

    context "a visitor" do
      it "returns a 403" do
        expect{
           post :create, params: {
                            article_id: article.id,
                            comment: {
                              body: :fake_body
                            }
                          }
                }.to change(Comment, :count).by 0

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end
  end

  context ".destroy" do
    context "a visitor" do
      it "returns a 403" do
        expect{
          delete :destroy, params: {
                              article_id: article.id,
                              id: comment.id
                            }
              }.to change(Comment, :count).by 0

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end

    context "a random user" do
      it "returns a 403" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(diff_user)
        expect{
          delete :destroy, params: {
                              article_id: article.id,
                              id: comment.id
                            }
              }.to change(Comment, :count).by 0

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end

    context "the comment author" do
      it "deletes the comment and redirects to the article" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)
        expect{
          delete :destroy, params: {
                              article_id: article.id,
                              id: comment.id
                            }
              }.to change(Comment, :count).by -1

        expect(response.status).to eq 302
        expect(response).to redirect_to article_path(article)
      end
    end

    context "the article author" do
      it "deletes the comment and redirects to the article" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        expect{
          delete :destroy, params: {
                              article_id: article.id,
                              id: comment.id
                            }
              }.to change(Comment, :count).by -1

        expect(response.status).to eq 302
        expect(response).to redirect_to article_path(article)
      end
    end

    context "an admin" do
      it "deletes the comment and redirects to the article" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
        expect{
          delete :destroy, params: {
                              article_id: article.id,
                              id: comment.id
                            }
              }.to change(Comment, :count).by -1

        expect(response.status).to eq 302
        expect(response).to redirect_to article_path(article)
      end
    end
  end

  context ".edit" do
    context "a visitor" do
      it "returns a 403" do
        get :edit, params: {
                            article_id: article.id,
                            id: comment.id
                          }

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end

    context "a random user" do
      it "returns a 403" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(diff_user)
        get :edit, params: {
                            article_id: article.id,
                            id: comment.id
                          }

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end

    context "the comment author" do
      it "renders the edit comment view" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)
        get :edit, params: {
                            article_id: article.id,
                            id: comment.id
                          }

        expect(response.status).to eq 200
        assert_template :edit
      end
    end

    context "the article author" do
      it "returns a 403" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        get :edit, params: {
                            article_id: article.id,
                            id: comment.id
                          }

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end

    context "an admin" do
      it "returns a 403" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
        get :edit, params: {
                            article_id: article.id,
                            id: comment.id
                          }

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end
  end

  context ".update" do
    context "a visitor" do
      it "returns a 403" do
        put :update, params: {
                            article_id: article.id,
                            id: comment.id,
                            comment: {
                              body: :more_different_body
                            }
                          }

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end

    context "a random user" do
      it "returns a 403" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(diff_user)
        put :update, params: {
                            article_id: article.id,
                            id: comment.id,
                            comment: {
                              body: :more_different_body
                            }
                          }

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end

    context "the comment author" do
      it "updates the comment and redirects to the article" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)
        put :update, params: {
                            article_id: article.id,
                            id: comment.id,
                            comment: {
                              body: :more_different_body
                            }
                          }

        expect(response.status).to eq 302
        expect(response).to redirect_to article_path(article)
      end
    end

    context "the article author" do
      it "returns a 403" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        put :update, params: {
                            article_id: article.id,
                            id: comment.id,
                            comment: {
                              body: :more_different_body
                            }
                          }

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end

    context "an admin" do
      it "returns a 403" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
        put :update, params: {
                            article_id: article.id,
                            id: comment.id,
                            comment: {
                              body: :more_different_body
                            }
                          }

        expect(response.status).to eq 403
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end
  end
end
