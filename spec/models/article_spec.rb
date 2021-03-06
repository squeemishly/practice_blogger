require 'rails_helper'

RSpec.describe Article, type: :model do
  attr_reader :user, :comment

  before(:each) do
    @user = create(:user)

    (1..15).each do |i|
      create(:article,
              title: "fake title #{i}",
              body: "fake body",
              user: user)
    end

    @comment = create(:comment,
                        user: user,
                        article: Article.last)
  end

  context "attributes" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
  end

  context "relationships" do
    it { should belong_to(:user) }
    it { should have_many(:comments) }

    it "will delete any comments when an article is deleted" do
      expect { Article.last.destroy }.to change { Comment.count }.by(-1)
    end

  end

  context "methods" do
    context ".articles_to_display" do
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

      it "returns the correct page number of articles requested" do
        articles = Article.articles_to_display(2, 2)
        article_titles = articles.map { |article| article.title }
        expected = ["fake title 13", "fake title 12"]

        expect(article_titles).to eq expected
      end
    end

    context ".most_comments" do
      it "returns the most commented on articles" do
        5.times do
          create(:comment, article: Article.last, user: user)
        end

        4.times do
          create(:comment, article: Article.first, user: user)
        end

        expected = [Article.last, Article.first]

        expect(Article.most_comments).to eq expected
      end
    end
  end
end
