ActiveAdmin.register User do
  actions :all, :except => [:destroy,:edit,:new]
  action_item :only => :show do
    link_to "Verify", verify_admin_user_path(user)
  end

  index do
    column "Email" do |user|
      link_to user.email, admin_user_path(user)
    end
    column :username
    column :confirmed_at
  end

  member_action :verify, :method => :get, :as => :block do
    # not a fan of sending full-on active record objects to the view but
    # it's par for the course here in activeadmin land
    @user  = User.find(params[:id])
    @user_meta = @user.user_meta
    @state = @user_meta.state
    @steps = @state.verify_wizard
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
        end
        tr do
          td do
            simple_format user.email
          end
          td do
            simple_format user.username
          end
          td do
            simple_format user.confirmed_at.strftime("%B %d, %Y @ %I:%M%p")
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
        end
      end
    end
  end
end
