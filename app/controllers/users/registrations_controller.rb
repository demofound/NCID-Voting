# this controller provides some customization for the devise registrations controller
class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :get_realms, :get_user, :only => [:new, :create, :edit, :update]

  def create
    # stupid stupid hack.  I don't know why user.registrations.build isn't setting the user_id foreign key GRRR
    params[:user][:registrations_attributes]["0"][:user_id] = current_or_guest_user.id
    super
  end

  protected

  def get_realms
    @states    = State.order("name").all.reject{|s| s[:code] == "FO"}
    @countries = Hash[*Country.order("name").all.map{|s| [s.name, s.code] }.flatten]
  end

  def get_user
    @user = current_or_guest_user
  end
end
