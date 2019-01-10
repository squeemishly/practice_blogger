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

        expect(articles).to be_an Array
        expect(articles.count).to eq 10
        expect(articles.first.title).to eq "fake title 15"
        expect(articles.last.title).to eq "fake title 6"
      end


      it "returns the number of articles requested" do
        articles = Article.articles_to_display(1, 5)

        expect(articles.count).to eq 5
        expect(articles.first).to be_an Article
        expect(articles.first.title).to eq "fake title 15"
        expect(articles.last.title).to eq "fake title 11"
        expect(articles.find { |article| article.title == "fake title 14"}).to be_an Article
        expect(articles.find { |article| article.title == "fake title 10"}).to be nil
      end
    end
  end
end
