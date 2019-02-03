require 'rails_helper'

describe CommentsController do
  context ".new" do
    context "a user" do
      it "renders the new page"
    end

    context "a visitor" do
      it "returns a 403"
    end
  end

  context ".create" do
    context "a user" do
      context "all the fields filled in" do
        it "renders the new page"
      end

      context "a field missing" do
        it "returns the user to the new comment path"
      end
    end

    context "a visitor" do
      it "returns a 403"
    end
  end

  context ".destroy" do
    context "a visitor" do
      it "returns a 403"
    end

    context "a random user" do
      it "returns a 403"
    end

    context "the comment author" do
      it "deletes the comment and redirects to the article"
    end

    context "the article author" do
      it "deletes the comment and redirects to the article"
    end

    context "an admin" do
      it "deletes the comment and redirects to the article"
    end
  end

  context ".edit" do
    context "a visitor" do
      it "returns a 403"
    end

    context "a random user" do
      it "returns a 403"
    end

    context "the comment author" do
      it "renders the edit comment view"
    end

    context "the article author" do
      it "returns a 403"
    end

    context "an admin" do
      it "returns a 403"
    end
  end

  context ".update" do
    context "a visitor" do
      it "returns a 403"
    end

    context "a random user" do
      it "returns a 403"
    end

    context "the comment author" do
      it "updates the comment and redirects to the article"
    end

    context "the article author" do
      it "returns a 403"
    end

    context "an admin" do
      it "returns a 403"
    end
  end
end
