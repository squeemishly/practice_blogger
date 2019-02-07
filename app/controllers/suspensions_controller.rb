class SuspensionsController < ApplicationController
  def create
    if current_admin?
      user = User.find(params[:user])
      Suspension.create(user: user, is_suspended: true)
      redirect_to user_path(user)
    else
      render_403
    end
  end

  def update
    if current_admin?
      user = User.find(params[:user])
      suspension = Suspension.find_by(user_id: user.id)
      suspension.update(is_suspended: false)
      redirect_to user_path(user)
    else
      render_403
    end
  end
end
