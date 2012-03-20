class UserController < ApplicationController
  before_filter :login_minus_usermeta_required, :only => [:collect_meta, :collect_meta_do]
  before_filter :get_state,                     :only => [:collect_meta, :collect_meta_do]
  before_filter :get_user,                      :only => [:collect_meta, :collect_meta_do]

  layout "active_admin_esque"

  def collect_meta
  end

  def collect_meta_do
    user_meta_data = {
      :fullname       => params[:user][:user_meta][:fullname],
      :street_address => params[:user][:user_meta][:street_address],
      :postal_code    => params[:user][:user_meta][:postal_code],
      :country_code   => params[:user][:user_meta][:country_code],
      :ssn            => params[:user][:user_meta][:ssn],
      :state_id       => params[:user][:state_code],
      :user_id        => current_user.id
    }

    unless @user_meta = UserMeta.create(user_meta_data)
      logger.info "unable to save user_meta #{user_meta_data.inspect} for user #{current_user.inspect}"

      # rerender the form
      return render :collect_meta
    end

    # TODO: try to locate the user in the voter DB
  end

  private

  # in order to collect user's meta information they have to be registered, logged in, but missing their metadata
  def login_minus_usermeta_required
    unless current_user.present? && current_user.needs_meta?
      return redirect_to new_user_session_path
    end
  end

  def get_user_meta
    @user_meta = current_user.user_meta
  end

  def get_state
    # this param will either come from the form post or from the get params
    state_code  = params[:state_code] || params[:user][:state_code]

    # do we have a real state?
    if state = State.first(:conditions => {:code => state_code})
      # state currently means domestic so we defer the requirements to the State
      @state = {
        :required_fields => state.required_fields,
        :code            => state.code
      }
    else
      # no state currently means foreign, so we'll just collect address and fullname by default
      @state = {
        :required_fields => [:address, :fullname]
      }
    end
  end
end
