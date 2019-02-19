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
      suspension = Suspension.where(user_id: user.id).order(created_at: :desc).limit(1)
      suspension.update(is_suspended: false)
      redirect_to user_path(user)
    else
      render_403
    end
  end

  def index
    if current_admin?
      @users = User.joins(:suspensions).uniq
    else
      render_403
    end
  end
end
