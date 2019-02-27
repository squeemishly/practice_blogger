class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  helper_method :current_user, :current_admin?

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_admin?
    current_user && current_user.admin?
  end

  def render_403
    render file: "/public/403", status: 403
  end
end
