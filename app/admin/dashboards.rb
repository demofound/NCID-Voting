ActiveAdmin::Dashboards.build do
  section "Users Requiring Verification" do
    table_for User.recent(20, {:verified_at => nil}) do
      column "" do |user|
        link_to "verify", verify_admin_user_path(user)
      end
      column :email
      column :username do |user|
        link_to user.username, [:admin, user]
      end
      # confirmed_at -> "registered at" label is to try to avoid confusion with verified_at
      column "Registered At", :confirmed_at
      column :state do |user|
        (meta = user.user_meta) ? meta.state.name : ""
      end
    end
  end

  section "Recent Initiatives" do
    table_for Initiative.recent(5) do
      column :name do |initiative|
        link_to initiative.name, [:admin, initiative]
      end
      column :start_at
      column :end_at
    end
  end
end
