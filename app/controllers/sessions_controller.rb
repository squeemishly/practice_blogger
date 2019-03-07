class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def new
  end

  def create
    @user = User.find_by(username: params[:session][:username])
    if @user && @user.authenticate(params[:session][:password])
      session[:user_id] = @user.id
      redirect_to articles_path
    else
      redirect_to '/login', alert: "Incorrect username or password"
    end
  end

  def destroy
    session.clear
    redirect_to login_path
  end
end
