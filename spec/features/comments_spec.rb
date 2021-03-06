require 'rails_helper'

describe "Article Comments" do
  attr_reader :user, :article, :admin, :rando_user, :comment, :diff_user

  before(:each) do
    @user = create(:user)
    @article = create(:article, user: user)
    @admin = create(:admin)
    @rando_user = create(:rando_user)
    @comment = create(:comment,
                        user: rando_user,
                        article: article)
    @diff_user = create(:diff_user)
  end

  describe "view all commments on an article" do
    it "allows all visitors to view all comments on an article" do
      (1..10).each do |i|
        create(:comment,
                user: rando_user,
                article: article,
                body: "Fake Comment #{i}")
      end

      visit article_path(article)

      expect(page).to have_content "Fake Comment 10"
      expect(page).to have_content rando_user.username
      expect(page).to have_content "Displaying comments 1 - 5 of 11 in total"
      expect(page).to_not have_content "Fake Comment 5"


      click_on "2"

      expect(page).to have_content "Fake Comment 5"
      expect(page).to have_content rando_user.username
      expect(page).to have_content "Displaying comments 6 - 10 of 11 in total"
      expect(page).to_not have_content "Fake Comment 10"

      click_on "Next"

      expect(page).to have_content "Fake Comment"
      expect(page).to have_content rando_user.username
      expect(page).to have_content "Displaying comment 11 - 11 of 11 in total"
      expect(page).to_not have_content "Fake Comment 10"
      expect(page).to_not have_content "Fake Comment 5"
    end

    context "suspended user comments" do
      context "a suspended user" do
        it "can see their own comments" do
          suspended_user = create(:user, username: "Suspended", email: "suspended@gmail.com")
          Suspension.create(user: suspended_user, is_suspended: true)
          comment = Comment.create(user: suspended_user, body: "Suspended Body", article: article)

          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(suspended_user)

          visit article_path(article)

          expect(page).to have_content comment.body
          expect(page).to have_link suspended_user.username
        end
      end

      context "a non-suspended user" do
        it "cannot see the comments of suspended users" do
          suspended_user = create(:user, username: "Suspended", email: "suspended@gmail.com")
          Suspension.create(user: suspended_user, is_suspended: true)
          comment = Comment.create(user: suspended_user, body: "Suspended Body", article: article)

          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

          visit article_path(article)

          expect(page).to_not have_content comment.body
          expect(page).to_not have_link suspended_user.username
        end
      end
    end
  end

  describe "add a comment to an article" do
    context "a visitor" do
      it "does not show the link to add a comment" do
        visit article_path(article)
        expect(page).to_not have_content "Add a Comment"

        visit new_article_comment_path(article)
        expect(page.status_code).to eq 403
        expect(page).to have_content "You are not authorized to enter this area."
      end
    end

    context "a user" do
      it "allows the user to add a comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)

        visit article_path(article)

        click_button "Add a Comment"
        expect(page).to have_current_path new_article_comment_path(article)

        fill_in "comment_body", with: "My New Comment"
        click_button "Share Your Thoughts!"

        expect(page).to have_current_path article_path(article)
        expect(page).to have_content "My New Comment"
        expect(page).to have_content rando_user.username
      end
    end
  end

  describe "edit a comment" do
    context "a visitor" do
      it "does not show the link to edit the comment" do
        visit article_path(article)
        expect(page).to_not have_content "Edit Comment"

        visit edit_article_comment_path(article, comment)
        expect(page.status_code).to eq 403
        expect(page).to have_content "You are not authorized to enter this area."
      end
    end

    context "a random user" do
      it "shows the link to edit their comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)

        visit article_path(article)

        expect(page).to have_content "Fake Comment"

        click_button "Edit Comment"
        expect(page).to have_current_path edit_article_comment_path(article, comment)

        fill_in "comment_body", with: "Totally edited Comment"
        click_button "Share Your Thoughts!"

        expect(page).to have_current_path article_path(article)
        expect(page).to have_content "Totally edited Comment"
        expect(page).to_not have_content "Fake Comment"
      end

      it "does not show the link to edit another user's comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(diff_user)

        visit article_path(article)
        expect(page).to_not have_content "Edit Comment"

        visit edit_article_comment_path(article, comment)
        expect(page.status_code).to eq 403
        expect(page).to have_content "You are not authorized to enter this area."
      end
    end

    context "the writer of the article" do
      it "does not show the link to edit another user's comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit article_path(article)
        expect(page).to_not have_content "Edit Comment"

        visit edit_article_comment_path(article, comment)
        expect(page.status_code).to eq 403
        expect(page).to have_content "You are not authorized to enter this area."
      end
    end

    context "the site admin" do
      it "does not show the link to edit another user's comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit article_path(article)
        expect(page).to_not have_content "Edit Comment"

        visit edit_article_comment_path(article, comment)
        expect(page.status_code).to eq 403
        expect(page).to have_content "You are not authorized to enter this area."
      end
    end
  end

  describe "delete a comment" do
    context "a visitor" do
      it "does not show the link to delete the comment" do
        visit article_path(article)

        expect(page).to_not have_content "Delete Comment"
      end
    end

    context "a random user" do
      it "shows the link to delete their own comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)

        visit article_path(article)
        expect(page).to have_content "Fake Comment"
        click_button "Delete Comment"

        expect(page).to have_current_path article_path(article)
        expect(page).to_not have_content "Fake Comment"
      end

      it "does not show the link to delete another user's comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(diff_user)

        visit article_path(article)

        expect(page).to_not have_content "Delete Comment"
      end
    end

    context "the writer of the article" do
      it "allows the user to delete any comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit article_path(article)
        expect(page).to have_content "Fake Comment"
        click_button "Delete Comment"

        expect(page).to have_current_path article_path(article)
        expect(page).to_not have_content "Fake Comment"
      end
    end

    context "the site admin" do
      it "shows the link to delete any comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit article_path(article)
        expect(page).to have_content "Fake Comment"
        click_button "Delete Comment"

        expect(page).to have_current_path article_path(article)
        expect(page).to_not have_content "Fake Comment"
      end
    end
  end
end
