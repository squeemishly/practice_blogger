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
    context ".create_comment" do
      it "should return a new comment" do
        user = User.create(
          first_name: "fake_first",
          last_name: "fake_last",
          email: "fake_email",
          password: "fakeyfakefake",
          username: "fake_user"
        )
        article = Article.create(
          user: user,
          title: "fake_title",
          body: "fake_body"
        )
        params = {body: "fake"}

        comment = Comment.create_comment(params, article, user)

        expect(comment).to be_a Comment
        expect(comment.body).to eq "fake"
        expect(comment.user).to eq user
        expect(comment.article).to eq article
      end
    end
  end
end
