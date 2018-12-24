class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to articles_path
    else
      flash[:alert] = "Please complete requirements before creating account"
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user == current_user || current_admin?
      @user.update!(user_params)
      redirect_to user_path(@user.id)
    else
      render file: "/public/404"
    end
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :username, :password)
    end
end
