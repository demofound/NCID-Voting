ActiveAdmin::Dashboards.build do
  section "Users Requiring Certification" do
    table_for User.recent(20, {:certified_at => nil, :certifier_id => nil}) do
      column "" do |user|
        link_to "certify", certify_admin_user_path(user)
      end
      column :email
      column :username do |user|
        link_to user.username, [:admin, user]
      end
      # confirmed_at -> "registered at" label is to try to avoid confusion with certified_at
      column "Registered At", :confirmed_at
      column :state do |user|
        (meta = user.user_meta) ? meta.state.name : ""
      end
    end
  end

  section "Active Initiatives" do
    table_for Initiative.active(5) do
      column :name do |initiative|
        link_to initiative.name, [:admin, initiative]
      end
      column :start_at
      column :end_at
      column :vote_count do |initiative|
        "#{initiative.votes.count} / #{initiative.votes_needed}"
      end
    end
  end
end
