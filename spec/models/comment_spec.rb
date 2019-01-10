require 'rails_helper'

RSpec.describe Comment, type: :model do
  context "attributes" do
    it { should validate_presence_of(:body) }
  end

  context "relationships" do
    it { should belong_to(:user) }
    it { should belong_to(:article) }
  end

  context "methods" do
    attr_reader :user, :article

    before(:each) do
      @user = User.create(
        first_name: :first_name,
        last_name: :last_name,
        username: :username,
        password: :my1pass!,
        email: "fake@fakey.com"
      )

      @article = Article.create(
          title: "fake title",
          body: "fake body",
          user: user
      )
    end

    after(:each) do
      Comment.all.each do |comment|
        comment.destroy
      end

      Article.all.each do |article|
        article.destroy
      end

      User.all.each do |user|
        user.destroy
      end
    end

    context ".create_comment" do
      it "should return a new comment" do
        params = {body: "fake"}

        comment = Comment.create_comment(params, article, user)

        expect(comment).to be_a Comment
        expect(comment.body).to eq "fake"
        expect(comment.user).to eq user
        expect(comment.article).to eq article
      end
    end

    context ".comments_to_display" do
      it "returns 5 comments for the article" do
        (1..10).each do |i|
          Comment.create(
            body: "fake comment #{i}",
            article: article,
            user: user
          )
        end

        comments = Comment.comments_to_display(article, nil)

        expect(comments).to be_an Array
        expect(comments.first).to be_a Comment
        expect(comments.first.body).to eq "fake comment 10"
        expect(comments.last.body).to eq "fake comment 6"
        expect(comments.find { |comment| comment.body == "fake comment 9"}).to be_a Comment
        expect(comments.find { |comment| comment.body == "fake comment 5"}).to be nil
      end
    end
  end
end
