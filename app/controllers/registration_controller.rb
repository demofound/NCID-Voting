class RegistrationController < ApplicationController
  layout "active_admin_esque"

  before_filter :login_minus_registration_required, :only => [:register_domestic, :register_do, :register_foreign]
  before_filter :get_state,                         :only => [:register_domestic, :register_do, :register_foreign]
  before_filter :new_registration,                  :only => [:register_domestic, :register_foreign]

  layout "active_admin_esque"

  def choose_location
    @states = State.order("name").all.map {|s| {:name => s.name, :code => s.code } }
  end

  # NOTE: @registration populated in before_filter
  def register_domestic
    return render "collect"
  end

  # NOTE: @registration populated in before_filter
  def register_foreign
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
      :user_id        => current_user.id
    }

    unless @registration = Registration.create(registration_data) and @registration.save
      logger.info "unable to save registration #{registration_data.inspect} for user #{current_user.inspect} because #{@registration.errors.inspect}"

      # rerender the form
      return render :collect
    end

    # TODO: try to locate the registration in the voter DB

    logger.info "voter #{registration_data.inspect} located in voter registration database"
    flash[:info] = "We have located you in our database."

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
    end

    # NOTE: no state currently implies foreign
  end

  # just an attempt to DRY up the international and domestic actions
  def new_registration
    @registration = Registration.new(:state_id => @state[:id])
  end

  # in order to collect user's registration information they have to have an account, logged in, but missing a registration
  def login_minus_registration_required
    unless current_user.present? && current_user.needs_registration?
      return redirect_to new_user_session_path
    end
  end
end
