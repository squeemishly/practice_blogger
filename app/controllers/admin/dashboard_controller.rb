class Admin::DashboardController < ApplicationController
  before_action :require_admin

  def show
    @articles = Article.order(updated_at: :desc).limit(10)

    if params[:user_search] && params[:user_search] != ""
      @users = User.where("lower(username) LIKE (?)", "%#{params[:user_search].downcase}%")
    end

    if params[:article_search] && params[:article_search] != ""
      users = User.where("lower(username) LIKE (?)", "%#{params[:article_search].downcase}%")
      @found_articles = users.map do |user|
        user.articles
      end.flatten
    end
  end

  private

    def require_admin
      render file: "/public/404" unless current_admin?
    end
end
