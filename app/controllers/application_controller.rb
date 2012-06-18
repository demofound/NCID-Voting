class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :pass_forward_url, :return_to_storage, :get_active_registrations

  layout :layout_by_resource

  protected

  # if user is logged in, return current_user, else return guest_user
  def current_or_guest_user
    if current_user
      if session[:guest_user_id]
        logging_in
        guest_user.destroy
        session[:guest_user_id] = nil
      end
      return current_user
    else
      return guest_user
    end
  end

  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_user
    User.find(session[:guest_user_id].nil? ? session[:guest_user_id] = create_guest_user.id : session[:guest_user_id])
  end

  # called (once) when the user logs in
  # hand off from guest_user to current_user
  def logging_in
    guest_user.votes.each do |v|
      unless v.update_attributes!(:user_id => current_user.id)
        logger.error "unable to swap vote #{v.inspect} from guest user #{guest_user.inspect} to user #{current_user.inspect}"
      end
    end

    unless registrations = guest_user.registrations and registrations.update_all(:user_id => current_user.id)
      logger.error "unable to swap registrations #{registrations.inspect} from guest user #{guest_user.inspect} to user #{current_user.inspect}"
    end

    unless current_user.update_attributes!(:current_registration_id => guest_user.current_registration_id)
        logger.error "unable to swap current registration from guest user #{guest_user.inspect} to user #{current_user.inspect}"
      end
  end

  def create_guest_user
    u = User.create(:email => "guest_#{Time.now.to_i}#{rand(99)}@not-an-actual-domain-at-all.com")
    u.save(:validate => false)
    return u
  end

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
    @current_or_guest_user = current_or_guest_user
    @active_registrations  = @current_or_guest_user.active_registrations
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
