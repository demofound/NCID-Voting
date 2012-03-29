class UserController < ApplicationController
  before_filter :login_minus_usermeta_required, :only => [:meta_domestic, :meta_do, :meta_foreign]
  before_filter :get_state,                     :only => [:meta_domestic, :meta_do, :meta_foreign]
  before_filter :get_user_meta,                 :only => [:meta_domestic, :meta_do, :meta_foreign]

  layout "active_admin_esque"

  def choose_location
    @states = State.order("name").all.map {|s| {:name => s.name, :code => s.code } }
  end

  def meta_domestic
    return render "collect_meta"
  end

  def meta_foreign
    return render "collect_meta"
  end

  def meta_do
    user_meta_data = {
      :fullname       => params[:user_meta][:fullname],
      :street_address => params[:user_meta][:street_address],
      :postal_code    => params[:user_meta][:postal_code],
      :country_code   => params[:user_meta][:country_code],
      :ssn            => params[:user_meta][:ssn],
      :state_id       => @state[:id],
      :user_id        => current_user.id
    }

    unless @user_meta = UserMeta.create(user_meta_data) and @user_meta.save
      logger.info "unable to save user_meta #{user_meta_data.inspect} for user #{current_user.inspect} because #{@user_meta.errors.inspect}"

      # rerender the form
      return render :collect_meta
    end

    # TODO: try to locate the user in the voter DB

    logger.info "voter #{user_meta_data.inspect} located in voter registration database"
    flash[:info] = "We have located you in our database."

    unless current_user.add_roles(:voter) and current_user.save
      logger.error "unable to assign user #{current_user.inspect} the voter role"
    end

    return redirect_to params[:forward_url] || root_path
  end

  private

  # in order to collect user's meta information they have to be registered, logged in, but missing their metadata
  def login_minus_usermeta_required
    unless current_user.present? && current_user.needs_meta?
      return redirect_to new_user_session_path
    end
  end

  def get_user_meta
    @user_meta = current_user.user_meta || UserMeta.new
  end

  def get_state
    # this param will either come from the form post or from the get params
    state_code  = params[:user].present? ? params[:user][:state_code] : params[:state_code]

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
end
