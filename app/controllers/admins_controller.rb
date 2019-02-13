class AdminsController < ApplicationController
  def new
    @user = User.find(params[:user_id])
    @user.update(role: 1)
    redirect_to user_path(@user)
  end

  def destroy
    @user = User.find(params[:id])
    @user.update(role: 0)
    redirect_to user_path(@user)
  end
end
