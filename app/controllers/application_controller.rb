class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  def login_required
    flash[:info] = "You need to register before you can proceed."
    return redirect_to new_user_registration_path
  end
end
