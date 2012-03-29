class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :redirect_if_user_meta_needed
  before_filter :pass_forward_url

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
      # forward_url allows us to hand the original URL that brought us here down the chain
      return redirect_to choose_location_user_path(:forward_url => request.path)
    end
  end

  def pass_forward_url
    # if we've been handed a forward_url, make it available to the views or whomever to handle
    @forward_url = params[:forward_url]
  end
end
