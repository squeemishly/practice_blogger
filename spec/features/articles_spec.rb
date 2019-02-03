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
  end

  describe "article index" do
    it "allows visitors to see all articles" do
      visit root_path

      expect(page).to have_content article.title
      expect(page).to have_content user.username
    end

    context "pagination" do
      it "automatically paginates after 10 articles" do
        (1..20).each do |i|
          Article.create(
            title: "fake title #{i}",
            body: "fake body",
            user: user
          )
        end

        visit root_path

        expect(page).to have_content "Displaying articles 1 - 10 of 21 in total"
        expect(page).to have_link "fake title 20"
        expect(page).to_not have_link "fake title 10"

        click_link "2"

        expect(page).to have_content "Displaying articles 11 - 20 of 21 in total"
        expect(page).to_not have_link "fake title 20"
        expect(page).to have_link "fake title 10"
      end

      it "allows the user to change the number of articles displayed" do
        (1..20).each do |i|
          Article.create(
            title: "fake title #{i}",
            body: "fake body",
            user: user
          )
        end

        visit root_path

        expect(page).to have_content "Displaying articles 1 - 10 of 21 in total"

        select('50', from: 'limit')
        click_button "Change Density"

        expect(page).to have_content "Displaying all 21 articles"
      end
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

    context "as the article author" do
      it "does shows and edit and a delete link" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit article_path(article.id)

        expect(page).to have_content article.title
        expect(page).to have_content article.body
        expect(page).to have_button "Edit Post"
        expect(page).to have_button "Delete Post"
      end
    end

    context "as a logged in user, but not the author" do
      it "does not show an edit or delete link" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)

        visit article_path(article.id)

        expect(page).to have_content article.title
        expect(page).to have_content article.body
        expect(page).to_not have_content "Edit Post"
        expect(page).to_not have_content "Delete Post"
      end
    end

    context "as a admin" do
      it "does not show an edit but does show a delete link" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit article_path(article.id)

        expect(page).to have_content article.title
        expect(page).to have_content article.body
        expect(page).to_not have_button "Edit Post"
        expect(page).to have_button "Delete Post"
      end
    end
  end

  describe "create a new article" do
    context "as a visitor" do
      it "does not have the new blog post link" do
        visit root_path

        expect(page).to_not have_content "Write New Blog Post"
        expect(page).to have_content "Login"

        visit new_article_path

        expect(page.status_code).to eq 403
        expect(page).to have_content "You are not authorized to enter this area."
      end

    end

    context "as a user" do
      it "has a link for a new blog post and takes you to the new page" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit root_path
        click_on "Write New Blog Post"

        expect(page).to have_current_path new_article_path

        fill_in "article_title", with: "Fake Title"
        fill_in "article_body", with: "Fake Body"
        click_button "Add Your Thoughts!"

        expect(page).to have_current_path "/articles/#{Article.last.id}"
        expect(page).to have_css("h1", text: "Fake Title")
        expect(page).to have_content("Fake Body")
      end
    end
  end

  describe "edit an article" do
    context "as a visitor" do
      it "does not see the links to edit" do
        visit article_path(article)

        expect(page).to_not have_link "Edit Post"

        visit edit_article_path(article)

        expect(page.status_code).to eq 403
        expect(page).to have_content "You are not authorized to enter this area."
      end
    end

    context "as a user who did not write the article" do
      it "does not see the links to edit" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)

        visit article_path(article)

        expect(page).to_not have_link "Edit Post"

        visit edit_article_path(article)

        expect(page.status_code).to eq 403
        expect(page).to have_content "You are not authorized to enter this area."
      end
    end

    context "as a site admin" do
      it "does not see the links to edit" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit article_path(article)

        expect(page).to_not have_link "Edit Post"

        visit edit_article_path(article)

        expect(page.status_code).to eq 403
        expect(page).to have_content "You are not authorized to enter this area."
      end
    end

    context "as the writer of the article" do
      it "uses the links to edit and update" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit article_path(article)

        expect(page).to have_css("h1", text: "Fake Title")
        click_button "Edit Post"
        expect(page).to have_current_path edit_article_path(article)

        fill_in "article_title", with: "New Fake Title"
        click_button "Add Your Thoughts!"

        expect(page).to have_current_path article_path(article)
        expect(page).to have_css("h1", text: "New Fake Title")
        expect(page).to have_content "Fake Body"
      end
    end
  end

  describe "delete an article" do
    context "a visitor" do
      it "does not have the Delete Post link" do
        visit article_path(article)

        expect(page).to_not have_link "Delete Post"
      end
    end

    context "a user who did not write the article" do
      it "does not have the Delete Post link" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando_user)

        visit article_path(article)

        expect(page).to_not have_link "Delete Post"
      end

    end

    context "a user who is the writer of the article" do
      it "can delete the article" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit article_path(article)
        expect(page).to have_content("Fake Title")

        click_button "Delete Post"

        expect(page).to have_current_path("/articles")
        expect(page).to_not have_content("Fake Title")
      end
    end

    context "a site admin" do
      it "can delete the article" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit article_path(article)
        expect(page).to have_content("Fake Title")

        click_button "Delete Post"

        expect(page).to have_current_path("/articles")
        expect(page).to_not have_content("Fake Title")
      end
    end
  end
end
