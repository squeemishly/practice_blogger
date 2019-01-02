require 'rails_helper'

describe "Articles pages" do
  attr_reader :user, :article, :admin, :rando_user

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
      user_id: user.id
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
  end

  after(:each) do
    Article.all.each do |article|
      article.delete
    end

    user.delete
  end

  describe "article index" do
    it "allows visitors to see all articles" do
      visit root_path

      expect(page).to have_content article.title
      expect(page).to have_content user.username
    end
  end

  describe "article show" do
    context "as a visitor" do
      it "does not show an edit or delete link" do
        visit article_path(article.id)

        expect(page).to have_content article.title
        expect(page).to have_content article.body
        expect(page).to_not have_content "Edit Post"
        expect(page).to_not have_content "Delete Post"
      end
    end

    context "as a user" do
      it "does shows and edit and a delete link" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit article_path(article.id)

        expect(page).to have_content article.title
        expect(page).to have_content article.body
        expect(page).to have_content "Edit Post"
        expect(page).to have_content "Delete Post"
      end
    end

    context "as a admin" do
      it "does not show an edit but does show a delete link" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit article_path(article.id)

        expect(page).to have_content article.title
        expect(page).to have_content article.body
        expect(page).to_not have_content "Edit Post"
        expect(page).to have_content "Delete Post"
      end
    end
  end

  describe "create a new article" do
    context "as a visitor" do
      it "does not have the new blog post link" do
        visit root_path

        expect(page).to_not have_content "Write New Blog Post"
        expect(page).to have_content "Login"
      end

    end

    context "as a user" do
      it "has a link for a new blog post and takes you to the new page" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit root_path
        click_on "Write New Blog Post"

        expect(page).to have_current_path "/articles/new"

        fill_in "article_title", with: "Fake Title"
        fill_in "article_body", with: "Fake Body"
        click_button "Add Your Thoughts!"

        expect(page).to have_css("h1", text: "Fake Title")
      end
    end
  end

  describe "edit an article" do
    context "as a visitor" do
      it "does not see the links to edit" do
        visit article_path(article.id)

        expect(page).to_not have_link "Edit Post"
      end
    end

    context "as a user who did not write the article" do
      it "does not see the links to edit" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)

        visit article_path(article.id)

        expect(page).to_not have_link "Edit Post"
      end
    end

    context "as the writer of the article" do
      it "uses the links to edit and update" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit article_path(article.id)

        click_link "Edit Post"
        expect(page).to have_current_path(edit_article_path(article.id))

        fill_in "article_title", with: "New Fake Title"
        click_button "Add Your Thoughts!"

        expect(page).to have_current_path(article_path(article.id))
        expect(page).to have_css("h1", text: "New Fake Title")
      end
    end

    context "as a site admin" do
      it "does not see the links to edit" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit article_path(article.id)

        expect(page).to_not have_link "Edit Post"
      end
    end
  end

  describe "delete an article" do
    context "as a visitor" do
      it "does not have the Delete Post link" do
        visit article_path(article.id)

        expect(page).to_not have_link "Delete Post"
      end
    end

    context "as a user who did not write the article" do
      it "does not have the Delete Post link" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)

        visit article_path(article.id)

        expect(page).to_not have_link "Delete Post"
      end

    end

    context "as the writer of the article" do
      it "can delete the article" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit article_path(article.id)

        click_link "Delete Post"

        expect(page).to have_current_path("/articles")
        expect(page).to_not have_content("Fake Title")
      end
    end

    context "as a site admin" do
      it "can delete the article" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit article_path(article.id)

        click_link "Delete Post"

        expect(page).to have_current_path("/articles")
        expect(page).to_not have_content("Fake Title")
      end
    end
  end
end