require 'rails_helper'

RSpec.describe Article, type: :model do
  context "attributes" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
  end

  context "relationships" do
    it { should belong_to(:user) }
    it { should have_many(:comments) }
  end

  context "methods" do
    context ".articles_to_display" do
      before(:each) do
        user = User.create(
          first_name: :first_name,
          last_name: :last_name,
          username: :username,
          password: :my1pass!,
          email: "fake@fakey.com"
        )

        (1..15).each do |i|
          Article.create(
            title: "fake title #{i}",
            body: "fake body",
            user: user
          )
        end
      end

      after(:each) do
        Article.all.each do |article|
          article.destroy
        end

        User.all.each do |user|
          user.destroy
        end
      end

      it "returns the 10 most recent articles by default" do
        articles = Article.articles_to_display(nil, nil)
        article_titles = articles.map { |article| article.title }
        expected = [
          "fake title 15",
          "fake title 14",
          "fake title 13",
          "fake title 12",
          "fake title 11",
          "fake title 10",
          "fake title 9",
          "fake title 8",
          "fake title 7",
          "fake title 6"
        ]

        expect(article_titles).to eq expected
      end


      it "returns the number of articles requested" do
        articles = Article.articles_to_display(1, 2)
        article_titles = articles.map { |article| article.title }
        expected = ["fake title 15", "fake title 14"]

        expect(article_titles).to eq expected
      end
    end
  end
end
