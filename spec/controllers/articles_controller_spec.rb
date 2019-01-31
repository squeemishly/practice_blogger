require 'rails_helper'

describe ArticlesController do
  context ".index" do
    it "returns a list of articles"
  end

  context ".show" do
    it "returns the article and it's comments"
  end

  context ".new" do
    context "a logged in user" do
      it "returns a new Article"
    end

    context "a visitor" do
      it "returns a 403"
    end
  end

  context ".create" do
    context "when all fields are filled in" do
      it "saves the article and redirects to Article show"
    end

    context "when a field is missing" do
      it "returns an alert"
    end
  end

  context ".edit" do
    context "a user is editing their own article" do
      it "returns the article"
    end

    context "a random user is editing an article" do
      it "returns a 403"
    end
  end

  context ".update" do
    context "a user is editing their own article" do
      it "updates the article"
    end

    context "a random user is updating the article" do
      it "returns a 403"
    end
  end

  context ".destroy" do
    context "an admin is deleting the article" do
      it "deletes the article and sends the user to the root path"
    end

    context "a user is deleting their own article" do
      it "deletes the article and sends the user to the root path"
    end

    context "a random user is deleting an article they didn't write" do
      it "returns a 403"
    end
  end
end
