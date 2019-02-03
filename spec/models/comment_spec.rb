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
      @user = create(:user)
      @article = create(:article, user: user)

      (1..3).each do |i|
        @comment = create(:comment,
                          user: user,
                          article: article,
                          body: "fake comment #{i}")
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
      it "returns the 5 most recent comments by default" do
        comments = Comment.comments_to_display(article, nil, 2)
        comment_bodies = comments.map { |comment| comment.body }
        expected = ["fake comment 3", "fake comment 2"]

        expect(comment_bodies).to eq expected
      end

      it "returns the correct comments for the page number" do
        comments = Comment.comments_to_display(article, 2, 2)
        comment_bodies = comments.map { |comment| comment.body }
        expected = ["fake comment 1"]

        expect(comment_bodies).to eq expected
      end
    end
  end
end
