class Admin::DashboardController < ApplicationController
  before_action :require_admin

  def show
    @articles = Article.order(updated_at: :desc).limit(10)

    if params[:user_search] && params[:user_search] != ""
      @users = User.where("lower(username) LIKE (?)", "%#{params[:user_search].downcase}%")
    end
  end

  private

    def require_admin
      render file: "/public/404" unless current_admin?
    end
end
