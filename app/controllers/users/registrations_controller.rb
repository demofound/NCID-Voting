# this controller provides some customization for the devise registrations controller
class Users::RegistrationsController < Devise::RegistrationsController
  # get_realms lives in the application controller
  before_filter :get_realms, :only => [:new, :create, :edit, :update]

  def create
    # stupid stupid hack.  I don't know why user.registrations.build isn't setting the user_id foreign key GRRR
#    params[:user][:registrations_attributes]["0"][:user_id] = current_user.id
    super
  end

  protected

  def after_sign_up_path_for(resource)
    return donate_path
  end
end
