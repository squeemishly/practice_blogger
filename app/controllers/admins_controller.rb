class AdminsController < ApplicationController
  def new
    if current_admin?
      @user = User.find(params[:user_id])
      @user.update(role: 1)
      redirect_to user_path(@user)
    else
      render_403
    end
  end

  def destroy
    if current_admin?
      @user = User.find(params[:id])
      @user.update(role: 0)
      redirect_to user_path(@user)
    else
      render_403
    end
  end
end
