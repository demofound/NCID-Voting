class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :redirect_if_user_meta_needed

  layout :layout_by_resource

  protected

  def layout_by_resource
    if devise_controller?
      "active_admin_esque" # we emulate the active_admin layout for consistancy
    else
      "application"
    end
  end

  def after_confirmation_path_for(user)
    return choose_location_user_path
  end

  # if we've got a user and the user doesn't have meta data
  # we need to force them to fill it out
  def redirect_if_user_meta_needed
    # these routes are needed for the user to fill out the meta data
    if [ choose_location_user_path,
         meta_domestic_user_path,
         meta_foreign_user_path,
         meta_do_user_path ].include? request.path

      return
    end

    if current_user && current_user.needs_meta?
      return redirect_to choose_location_user_path
    end
  end
end
