ActiveAdmin.register User do
  # these bulk CRUDy actions are deprecated by our custom actions
  actions :all, :except => [:destroy,:edit,:new]

  # buttons for taking actions on users...

  # FIXME: it'd be great to only show these buttons if the current user can actually
  # perform these actions and if the user in question needs them performed...
  action_item :only => :show do
    link_to "Certify", certify_admin_user_path(user)
  end

  action_item :only => :show do
    link_to "Change Roles", roles_admin_user_path(user)
  end

  action_item :only => :certify do
    link_to "Abandon this Certification", abandon_certification_admin_user_path(@user)
  end

  # actions available for users...

  # index of all users in the system
  index do
    column "Email" do |user|
      link_to user.email, admin_user_path(user)
    end
    column :username
    column :confirmed_at
    column :certified_at
  end

  # provides the page for changing a user's roles
  # NOTE: obviously dangerous
  member_action :roles, :method => :get, :as => :block do
    @available_roles = ROLES
  end

  # provides handling for submission of changed user roles
  # NOTE: obviously dangerous
  member_action :roles_do, :method => :post, :as => :block do
    roles = params[:roles].split(",").map{|r| r.strip}

    # because this assignment works against a mask of valid values it should never fail
    @user.roles = roles
    @user.save

    flash[:info] = "We have updated the user's roles."
    return redirect_to admin_user_path(@certifyee)
  end

  # this is the method that handles displaying the certification wizard
  # NOTE: there are a lot of before filters that run before this method, which are found at the bottom of this file
  member_action :certify, :method => :get, :as => :block do
    @certifyee_meta = @certifyee.user_meta
    @state = @certifyee_meta.state
    @steps = @state.certify_wizard
  end

  # this is the method that handles certifiers acting on a certifyee
  # NOTE: there are a lot of before filters that run before this method, which are found at the bottom of this file
  member_action :certify_do, :method => :post, :as => :block do
    unless certification = params[:certification]
      flash[:info] = "You didn't specify a certification decision."
      return redirect_to certify_admin_user_path(@certifyee)
    end

    # attempt to certify the user yay or nay
    unless @certifyee.certify!(current_user, certification)
      logger.error "unable to certify the user #{@certifyee.inspect}"
      flash[:error] = "We weren't able to document your certification at this time."
      return redirect_to certify_admin_user_path(@certifyee)
    end

    flash[:info] = "We've successfully documented your certification of this user."
    return redirect_to admin_user_path(@certifyee)
  end

  member_action :abandon_certification do
    unless @certifyee.unlock!(current_user)
      logger.error "unable to abandon certification for user #{@certifyee.inspect}"
      flash[:error] = "We weren't able to abandon your certification."
      return redirect_to certify_admin_user_path(@certifyee)
    end

    flash[:info] = "You have abandoned your certification."
    return redirect_to admin_user_path(@certifyee)
  end

  # handles the displaying of users
  # NOTE: there are several levels of user involvement that we have to take into account:
  #       1. user is registered but hasn't confirmed their email
  #       2. user is confirmed but hasn't provided meta data about their eligibility
  #       3. user has provided meta data for certification but hasn't voted
  #       4. user has voted but hasn't been certified
  #       5. voter has been certified
  show :as => :block, :title => :email do |user|
    user_meta = user.user_meta

    div :for => user do
      table :class => "index_table" do
        tr do
          th do
            "Email"
          end
          th do
            "Username"
          end
          th do
            "Roles"
          end
          th do
            "Registered At"
          end
          if user_meta
            th do
              "Full Name"
            end
            th do
              "State"
            end
            th do
              "Postal Code"
            end
          end
          th do
            "Certified At"
          end
          th do
            "Certification"
          end
          th do
            "Certifier"
          end
        end
        tr do
          td do
            simple_format user.email
          end
          td do
            simple_format user.username
          end
          td do
            simple_format user.roles.to_sentence
          end
          td do
            simple_format user.confirmed_at ? user.confirmed_at.strftime("%B %d, %Y @ %I:%M%p") : ""
          end
          if user_meta
            td do
              user_meta.fullname
            end
            td do
              (state = user_meta.state) ? state.name : ""
            end
            td do
              user_meta.postal_code
            end
          end
          td do
            simple_format user.certified_at ? user.certified_at.strftime("%B %d, %Y @ %I:%M%p") : ""
          end
          td do
            simple_format user.certification.to_s
          end
          td do
            simple_format user.certifier ? user.certifier.username : ""
          end
        end
      end
    end
  end

  # the following code basically operates on the underlying standard Rails controller generated by the ActiveAdmin framework
  controller do
    before_filter :get_user,            :only => [:roles, :roles_do]
    before_filter :can_manage,          :only => [:roles, :roles_do]

    before_filter :get_certifyee,       :only => [:certify, :certify_do, :abandon_certification]
    before_filter :needs_certification, :only => [:certify, :certify_do, :abandon_certification]
    before_filter :can_certify,         :only => [:certify, :certify_do, :abandon_certification]
    before_filter :lock_certifyee,      :only => [:certify, :certify_do]

    protected

    ## user management filters

    def get_user
      unless @user = User.find(params[:id])
        flash[:error] = "Unable to find that user."
        return redirect_to admin_users_path
      end
    end

    def can_manage
      authorize! :update, @user
    end

    ## certification filters

    # we try to get the user to be certified
    def get_certifyee
      # not a fan of sending full-on active record objects to the view but
      # it's par for the course here in activeadmin land
      unless @certifyee = User.find(params[:id])
        flash[:error] = "Unable to find that user."
        return redirect_to admin_users_path
      end
    end

    # we verify that the current admin has the ability to certify users
    def can_certify
      authorize! :certify, @certifyee
    end

    def needs_certification
      # are they being certified by someone else?
      if @certifyee.locked?(current_user)
        certifier = @certifyee.certifier
        flash[:error] = "This user is currently locked by #{certifier.username} (#{certifier.email}).  Bother them."
        return redirect_to admin_user_path(@certifyee)
      end

      # we check to make sure that the user to be certified actually needs to be certified
      unless @certifyee.needs_certification?
        flash[:error] = "This user has already been certified."
        return redirect_to admin_user_path(@certifyee)
      end
    end

    def lock_certifyee
      @certifyee.lock!(current_user)
    end
  end
end
