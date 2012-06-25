class RegistrationController < ApplicationController
  before_filter :has_account?
  before_filter :get_realms,       :only => [:new, :create]
  before_filter :new_registration, :only => [:new]

  layout "active_admin_esque"

  def edit
    message = current_user.change_current_registration(params[:current_registration]) ? "Registration changed!" :
      "Registration could not be changed."

    flash[:info] = message
    return redirect_to session[:return_to]
  end

  # NOTE: @registration populated in before_filter
  def new
  end

  def create
    registration_data = params[:registration][:registrations]
    registration_data[:user_id] = current_user.id

    unless @registration = Registration.create(registration_data) and @registration.save
      logger.info "unable to save registration #{registration_data.inspect} for user #{current_user.inspect} because #{@registration.errors.inspect}"

      # rerender the form
      return render :new
    end

    flash[:info] = "Your registration has been saved and will be certified by a certifier soon."
    return redirect_to params[:forward_url] || root_path
  end

  private

  def new_registration
    # decided to disable the registration uniqueness behavior based on feedback from the NCID team
    # # do they already have a registration waiting certification? to avoid overloading
    # # the certifiers we only allow one pending registration at a time
    # if registration_pending = current_user.current_registration and !registration_pending.certified?
    #   logger.warn "user #{current_user} tried to create a new registration when they already one pending #{registration_pending.inspect}"
    #   flash[:warning] = "You already have a registration pending certification. Please wait for this registration to be certified."
    #   return redirect_to session[:return_to] # send them back
    # end

    # okay, they don't have a pending certification
    @registration = Registration.new(:user_id => current_user.id)
  end

  def has_account?
    unless current_user.present?
      flash[:error] = "You will need to create an account to do that."
      return redirect_to new_user_registration_path
    end
  end
end
