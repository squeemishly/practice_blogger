class SuspensionsController < ApplicationController
  def create
    user = User.find(params[:user])
    user.suspensions.create(user: user, is_suspended: true)
    redirect_to user_path(user)
  end

  def update
    user = User.find(params[:user])
    suspension = Suspension.find_by(user_id: user.id)
    suspension.update(is_suspended: false)
    redirect_to user_path(user)
  end
end
