require 'rails_helper'

describe "Article Comments" do
  attr_reader :user, :article, :admin, :rando_user, :comment, :diff_user

  before(:each) do
    @user = User.create!(
      first_name: "FakeFirst",
      last_name: "FakeLast",
      username: "Fakeyfakefake",
      password: "fakepass",
      email: "fake@fake.com",
      role: "default"
    )

    @article = Article.create!(
      title: "Fake Title",
      body: "Fake Body",
      user: user
    )

    @admin = User.create!(
      first_name: "FakeFirst",
      last_name: "FakeLast",
      username: "admin",
      password: "fakepass",
      email: "admin@admin.com",
      role: "admin"
    )

    @rando_user = User.create!(
      first_name: "FakeFirst",
      last_name: "FakeLast",
      username: "randouser",
      password: "randopass",
      email: "rando@rando.com",
      role: "default"
    )

    @comment = Comment.create!(
      article: article,
      user: rando_user,
      body: "Fake Comment"
    )

    @diff_user = User.create!(
      first_name: "FakeFirst",
      last_name: "FakeLast",
      username: "diffuser",
      password: "diffpass",
      email: "diff@diff.com",
      role: "default"
    )
  end

  after(:each) do
    Comment.all.each do |comment|
      comment.delete
    end

    Article.all.each do |article|
      article.delete
    end

    User.all.each do |user|
      user.delete
    end
  end

  describe "view all commments on an article" do
    it "allows all visitors to view all comments on an article" do
      (1..10).each do |i|
        Comment.create!(
          article: article,
          user: rando_user,
          body: "Fake Comment #{i}"
        )
      end

      visit article_path(article.id)

      expect(page).to have_content "Fake Comment 10"
      expect(page).to have_content "Contributed By: #{rando_user.username}"
      expect(page).to have_content "Displaying comments 1 - 5 of 11 in total"
      expect(page).to_not have_content "Fake Comment 5"


      click_on "2"

      expect(page).to have_content "Fake Comment 5"
      expect(page).to have_content "Contributed By: #{rando_user.username}"
      expect(page).to have_content "Displaying comments 6 - 10 of 11 in total"
      expect(page).to_not have_content "Fake Comment 10"

      click_on "Next"

      expect(page).to have_content "Fake Comment"
      expect(page).to have_content "Contributed By: #{rando_user.username}"
      expect(page).to have_content "Displaying comment 11 - 11 of 11 in total"
      expect(page).to_not have_content "Fake Comment 10"
      expect(page).to_not have_content "Fake Comment 5"
    end
  end

  describe "add a comment to an article" do
    context "as a visitor" do
      it "does not show the link to add a comment" do
        visit article_path(article.id)

        expect(page).to_not have_content "Add a Comment"
      end
    end

    context "as a user" do
      it "allows the user to add a comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)

        visit article_path(article.id)

        click_link "Add a Comment"
        expect(page).to have_current_path(new_article_comment_path(article.id))

        fill_in "comment_body", with: "My New Comment"
        click_button "Share Your Thoughts!"

        expect(page).to have_current_path(article_path(article.id))
        expect(page).to have_content "My New Comment"
        expect(page).to have_content "Contributed By: #{rando_user.username}"
      end
    end
  end

  describe "edit a comment" do
    context "as a visitor" do
      it "does not show the link to edit the comment" do
        visit article_path(article.id)

        expect(page).to_not have_content "Edit Comment"
      end
    end

    context "as a random user" do
      it "shows the link to edit their comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)

        visit article_path(article.id)

        click_link "Edit Comment"
        expect(page).to have_current_path(edit_article_comment_path(article.id, comment.id))

        fill_in "comment_body", with: "Totally edited Comment"
        click_button "Share Your Thoughts!"

        expect(page).to have_current_path(article_path(article.id))
        expect(page).to have_content "Totally edited Comment"
        expect(page).to have_content "Contributed By: #{rando_user.username}"
      end

      it "does not show the link to edit another user's comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(diff_user)

        visit article_path(article.id)

        expect(page).to_not have_content "Edit Comment"
      end
    end

    context "as the writer of the article" do
      it "does not show the link to edit another user's comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit article_path(article.id)

        expect(page).to_not have_content "Edit Comment"
      end
    end

    context "as the site admin" do
      it "does not show the link to edit another user's comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit article_path(article.id)

        expect(page).to_not have_content "Edit Comment"
      end
    end
  end

  describe "delete a comment" do
    context "as a visitor" do
      it "does not show the link to delete the comment" do
        visit article_path(article.id)

        expect(page).to_not have_content "Delete Comment"
      end
    end

    context "as a random user" do
      it "shows the link to delete their own comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)

        visit article_path(article.id)

        expect(page).to have_content "Fake Comment"

        click_link "Delete Comment"

        expect(page).to have_current_path(article_path(article.id))
        expect(page).to_not have_content "Fake Comment"
      end

      it "does not show the link to delete another user's comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(diff_user)

        visit article_path(article.id)

        expect(page).to_not have_content "Delete Comment"
      end
    end

    context "as the writer of the article" do
      it "shows the link to delete any comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit article_path(article.id)

        expect(page).to have_content "Fake Comment"

        click_link "Delete Comment"

        expect(page).to have_current_path(article_path(article.id))
        expect(page).to_not have_content "Fake Comment"
      end
    end

    context "as the site admin" do
      it "shows the link to delete any comment" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit article_path(article.id)

        expect(page).to have_content "Fake Comment"

        click_link "Delete Comment"

        expect(page).to have_current_path(article_path(article.id))
        expect(page).to_not have_content "Fake Comment"
      end
    end
  end
end
