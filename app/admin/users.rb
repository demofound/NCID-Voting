ActiveAdmin.register User do
  index do
    column "Email" do |user|
      link_to user.email, admin_user_path(user)
    end
    column :username
    column :confirmed_at
  end

  show :as => :block do |user|
    user_meta = user.user_meta

    div :for => user do
      h2 auto_link ("#{user.email} (#{user_meta ? user_meta.fullname : ''})")
      table :class => "index_table" do
        tr do
          th do
            "Email"
          end
          th do
            "Username"
          end
          th do
            "Confirmed At"
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
