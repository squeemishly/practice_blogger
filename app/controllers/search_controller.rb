class SearchController < ApplicationController
  def show
    if params[:article_search] && params[:article_search] != ""
      users = User.where("lower(username) LIKE (?)", "%#{params[:article_search].downcase}%")
      @found_articles = users.map do |user|
        user.articles
      end.flatten
    else
      redirect_to request.referrer
    end
  end
end
