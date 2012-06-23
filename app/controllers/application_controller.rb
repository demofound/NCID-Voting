class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :pass_forward_url, :return_to_storage, :get_active_registrations

  layout :layout_by_resource

  protected

  # called (once) when the user logs in
  # hand off from guest_user to current_user
  # def logging_in
  #   guest_user.votes.each do |v|
  #     unless v.update_attributes!(:user_id => current_user.id)
  #       logger.error "unable to swap vote #{v.inspect} from guest user #{guest_user.inspect} to user #{current_user.inspect}"
  #     end
  #   end

  #   unless registrations = guest_user.registrations and registrations.update_all(:user_id => current_user.id)
  #     logger.error "unable to swap registrations #{registrations.inspect} from guest user #{guest_user.inspect} to user #{current_user.inspect}"
  #   end

  #   unless current_user.update_attributes!(:current_registration_id => guest_user.current_registration_id)
  #       logger.error "unable to swap current registration from guest user #{guest_user.inspect} to user #{current_user.inspect}"
  #     end
  # end

  def layout_by_resource
    if devise_controller?
      "active_admin_esque" # we emulate the active_admin layout for consistancy
    else
      "application"
    end
  end

  def after_confirmation_path_for(user)
    return edit_user_path
  end

  def pass_forward_url
    # if we've been handed a forward_url, make it available to the views or whomever to handle
    @forward_url = params[:forward_url]
  end

  def get_active_registrations
    @active_registrations  = @current_user.active_registrations if @current_user = current_user
  end

  def session_required
    unless current_user.present?
      return redirect_to new_user_registration_path
    end
  end

  def return_to_storage
    session[:return_to] ||= request.referer
  end
end
