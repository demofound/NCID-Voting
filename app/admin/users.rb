ActiveAdmin.register User do
  actions :all, :except => [:destroy,:edit,:new]
  action_item :only => :show do
    link_to "Certify", certify_admin_user_path(user)
  end

  index do
    column "Email" do |user|
      link_to user.email, admin_user_path(user)
    end
    column :username
    column :confirmed_at
    column :certified_at
  end

  member_action :certify, :method => :get, :as => :block do
    @certifyee_meta = @certifyee.user_meta
    @state = @certifyee_meta.state
    @steps = @state.certify_wizard
  end

  member_action :certify_do, :method => :post, :as => :block do
    certification = params[:certification] # should be true or false
    unless @certifyee.certify!(current_user, certification)
      logger.error "unable to certify the user #{@certifyee.inspect}"
      flash[:error] = "We weren't able to document your certification at this time."
      return redirect_to certify_admin_user_path(@certifyee)
    end

    flash[:info] = "We've successfully documented your certification of this user."
    return redirect_to admin_user_path(@certifyee)
  end

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

  controller do
    before_filter :get_certifyee,       :only => [:certify, :certify_do]
    before_filter :needs_certification, :only => [:certify, :certify_do]
    before_filter :can_certify,         :only => [:certify, :certify_do]
    before_filter :lock_certifyee,      :only => [:certify, :certify_do]

    protected

    # we try to get the user to be certified
    def get_certifyee
      # not a fan of sending full-on active record objects to the view but
      # it's par for the course here in activeadmin land
      @certifyee = User.find(params[:id])
    end

    # we verify that the current admin has the ability to certify users
    def can_certify
      authorize! :certify, @certifyee
    end

    def needs_certification
      # are they being certified by someone else?
      if @certifyee.locked?(current_user)
        flash[:error] = "This user is currently locked by #{@certifyee.certifier.email}.  Bother them."
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
