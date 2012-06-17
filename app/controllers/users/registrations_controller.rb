# this controller provides some customization for the devise registrations controller
class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :get_realms,          :only => [:new, :update]

  def create
    registration_input = params[:user].delete :registration

    # I'm not a huge fan of mass assignment. I prefer to build a structure like this.
    registration_data = {
      :fullname       => registration_input[:fullname],
      :street_address => registration_input[:street_address],
      :postal_code    => registration_input[:postal_code],
      :country_code   => registration_input[:country_code],
      :ssn            => registration_input[:ssn],
      :state_id       => registration_input[:state_id],
      :user_id        => current_or_guest_user.id
    }

    # when we save this registration it will be saved on the *guest account* because the
    # user has not been made yet.  we will switch the registration over when they confirm
    unless registration = Registration.new(registration_data) and registration.save
      logger.info "unable to save registration #{registration_data.inspect} for user #{current_or_guest_user.inspect} because #{registration.errors.inspect}"

      # rerender the form
      respond_with resource
    end

    super # back to devise's normal execution
  end

  protected

  def get_realms
    @states    = State.order("name").all.reject{|s| s[:code] == "FO"}
    @countries = Hash[*Country.all.map{|s| [s.name, s.code] }.flatten]
  end
end
