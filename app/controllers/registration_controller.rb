class RegistrationController < ApplicationController
  before_filter :session_required
  before_filter :get_state,                         :only => [:register, :register_do]
  before_filter :new_registration,                  :only => [:register]

  layout "active_admin_esque"

  def choose_location
    # exclude the 'stub' foreign state used to glue together foreign registrations
    @states = State.order("name").all.map {|s| {:name => s.name, :code => s.code } }.reject{|s| s[:code] == "FO"}
  end

  # NOTE: @registration populated in before_filter
  def register
    @countries = Hash[*Country.all.map{|s| [s.name, s.code] }.flatten]
    return render "collect"
  end

  def register_do
    registration_data = {
      :fullname       => params[:registration][:fullname],
      :street_address => params[:registration][:street_address],
      :postal_code    => params[:registration][:postal_code],
      :country_code   => params[:registration][:country_code],
      :ssn            => params[:registration][:ssn],
      :state_id       => @state[:id],
      :user_id        => current_or_guest_user.id
    }

    unless @registration = Registration.create(registration_data) and @registration.save
      logger.info "unable to save registration #{registration_data.inspect} for user #{current_or_guest_user.inspect} because #{@registration.errors.inspect}"

      # rerender the form
      return render :collect
    end

    flash[:info] = "Your registration has been saved and will be certified by a certifier soon."
    return redirect_to params[:forward_url] || root_path
  end

  private

  def get_state
    # this param will either come from the form post or from the get params
    state_code  = params[:registration].present? ? params[:registration][:state_code] : params[:state_code]

    @state = {
      :required_fields => State.anywhere_fields # default to the fields that apply anywhere
    }

    if state = State.first(:conditions => {:code => state_code})
      @state.merge! :code => state.code
      @state.merge! :id   => state.id

      # if we have more specific requirements, use them
      @state.merge! :required_fields => state.required_fields if state.required_fields.present?
    else
      @state[:required_fields] << :country_code
    end
  end

  def new_registration
    # decided to disable the registration uniqueness behavior based on feedback from the NCID team
    # # do they already have a registration waiting certification? to avoid overloading
    # # the certifiers we only allow one pending registration at a time
    # if registration_pending = current_or_guest_user.current_registration and !registration_pending.certified?
    #   logger.warn "user #{current_or_guest_user} tried to create a new registration when they already one pending #{registration_pending.inspect}"
    #   flash[:warning] = "You already have a registration pending certification. Please wait for this registration to be certified."
    #   return redirect_to session[:return_to] # send them back
    # end

    # okay, they don't have a pending certification
    @registration = Registration.new(:state_id => @state[:id])
  end
end
