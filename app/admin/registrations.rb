ActiveAdmin.register Registration do
  # these bulk CRUDy actions are deprecated by our custom actions
  # and are kinda dangerous
  actions :all, :except => [:destroy,:edit,:new]

  # buttons for taking special actions on Registrations...

  # FIXME: it'd be great to only show these buttons if the current user can actually
  # perform these actions and if the registration in question needs them performed...
  action_item :only => :show do
    link_to "Certify", certify_admin_registration_path(registration)
  end

  #  action_item :only => :show do
  #    link_to "Leave Comment", comment_admin_user_path(registration)
  #  end

  action_item :only => :show do
    link_to registration.needs_review ? "Unflag" : "Flag for Review", registration.needs_review ? unflag_for_review_admin_registration_path(registration) : flag_for_review_admin_registration_path(registration), :class => registration.needs_review ? "important" : ""
  end

  action_item :only => :certify do
    link_to "Abandon this Certification", abandon_certification_admin_registration_path(@registration)
  end

  # actions available for registrations...

  # index of all registrations in the system
  index do
    column :id do |registration|
      link_to registration.id, admin_registration_path(registration)
    end
    column :state
    column "User" do |registration|
      link_to registration.user.email, admin_user_path(registration.user)
    end
    column :created_at
    column :certified_at
  end

  # this is the method that handles displaying the certification wizard
  # NOTE: there are a lot of before filters that run before this method, which are found at the bottom of this file
  member_action :certify, :method => :get, :as => :block do
    @state = @registration.state
    @steps = @state.certify_wizard
  end

  # this is the method that handles certifiers acting on a certifyee
  # NOTE: there are a lot of before filters that run before this method, which are found at the bottom of this file
  member_action :certify_do, :method => :post, :as => :block do
    unless certification = params[:certification]
      flash[:info] = "You didn't specify a certification decision."
      return redirect_to certify_admin_registration_path(@registration)
    end

    # attempt to certify the registration yay or nay
    unless @registration.certify!(current_user, certification)
      logger.error "unable to certify the registration #{@registration.inspect}"
      flash[:error] = "We weren't able to document your certification at this time."
      return redirect_to certify_admin_registration_path(@certifyee)
    end

    flash[:info] = "We've successfully documented your certification of this registration."
    return redirect_to admin_registration_path(@certifyee)
  end

  member_action :abandon_certification do
    unless @registration.unlock!(current_user)
      logger.error "unable to abandon certification for registration #{@registration.inspect}"
      flash[:error] = "We weren't able to abandon your certification."
      return redirect_to certify_admin_registration_path(@registration)
    end

    flash[:info] = "You have abandoned your certification."
    return redirect_to admin_registration_path(@registration)
  end

  # yeah I know the flagging methods below are doing write operations on
  # GET requests.  I am normally against this but whatever.

  # NOTE: certifiers can flag, not just admins
  member_action :flag_for_review, :method => :get, :as => :block do
    unless @registration.update_attributes!(:needs_review => true)
      logger.error "unable to flag registration #{@registration.inspect} for review"
      flash[:error] = "We were not able to flag the registration for review."
    else
      flash[:info] = "Registration flagged for review."
    end

    return redirect_to admin_registration_path(@registration)
  end

  # NOTE: certifiers can flag, not just admins
  member_action :unflag_for_review, :method => :get, :as => :block do
    unless @registration.update_attributes!(:needs_review => false)
      logger.error "unable to unflag registration #{@registration.inspect} for review"
      flash[:error] = "We were not able to unflag the registration."
    else
      flash[:info] = "Registration is unflagged."
    end

    return redirect_to admin_registration_path(@registration)
  end

  # handles the displaying of registrations
  show :as => :block do |registration|
    @registration = registration
    @user         = registration.user
    div :for => registration do
      table :class => "index_table" do
        tr do
          th do
            "Email"
          end
          th do
            "Full Name"
          end
          th do
            "Street Address"
          end
          th do
            "SSN"
          end
          th do
            "Country Code"
          end
          th do
            "State"
          end
          th do
            "Postal Code"
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
            link_to @user.email, admin_user_path(@user)
          end
          td do
            registration.fullname
          end
          td do
            registration.street_address
          end
          td do
            registration.ssn
          end
          td do
            registration.country_code
          end
          td do
            (state = registration.state) ? state.name : ""
          end
          td do
            registration.postal_code
          end
          td do
            simple_format registration.certified_at ? registration.certified_at.strftime("%B %d, %Y @ %I:%M%p") : ""
          end
          td do
            simple_format registration.certification.to_s
          end
          td do
            simple_format registration.certifier ? registration.certifier.username : ""
          end
        end
      end

      div :for => registration do
        h3 "Votes"
        table :class => "index_table" do
          tr do
            th do
              "ID"
            end
            th do
              "Initiative"
            end
            th do
              "Created At"
            end
          end
          registration.votes.each do |vote|
            tr do
              td do
                vote.id
              end
              td do
                link_to vote.initiative.name, admin_initiative_path(vote.initiative)
              end
              td do
                vote.created_at.strftime("%B %d, %Y @ %I:%M%p")
              end
            end
          end
        end
      end

      revision_table(registration)
    end
  end

  # the following code basically operates on the underlying standard Rails controller generated by the ActiveAdmin framework
  controller do
    before_filter :get_registration,    :only => [:certify, :certify_do, :abandon_certification]
    before_filter :needs_certification?, :only => [:certify, :certify_do, :abandon_certification]
    before_filter :can_certify,         :only => [
      :certify,
      :certify_do,
      :abandon_certification,
      :flag_for_review,
      :unflag_for_review]

    before_filter :lock_registration,   :only => [:certify, :certify_do]

    protected

    ## certification filters

    def get_registration
      unless @registration = Registration.find(params[:id])
        flash[:error] = "Unable to find that registration."
        return redirect_to admin_registration_path
      end

      @user = @registration.user
    end

    # we verify that the current admin has the ability to certify users
    def can_certify
      authorize! :certify, @registration
    end

    def needs_certification?
      # is the registration being certified by someone else?
      if @registration.locked?(current_user)
        certifier = @registration.certifier
        flash[:error] = "This registration is currently locked by #{certifier.username} (#{certifier.email}).  Bother them."
        return redirect_to admin_registration_path(@registration)
      end

      # we check to make sure that the registration to be certified actually needs to be certified
      unless !@registration.certified?
        flash[:error] = "This registration has already been certified."
        return redirect_to admin_registration_path(@registration)
      end
    end

    def lock_registration
      @registration.lock!(current_user)
    end
  end
end
