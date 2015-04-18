class UserController < ApplicationController
  before_filter :get_user
  before_filter :session_required

  def edit
  end

  def update
    user_data = {
      :avatar => params[:user] && params[:user][:avatar]
    }

    unless @user.update_attributes!(user_data)
      logger.error "unable to update #{@user.inspect} with data #{user_data.inspect}"
      flash[:error] = "There was an issue updating your account."
    end

    flash[:info] = "Your account has been updated."
    return redirect_to edit_user_path(@user)
  end

  protected

  def get_user
    @user = current_user
  end
end
