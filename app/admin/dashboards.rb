ActiveAdmin::Dashboards.build do
  section "Registrations Requiring Certification", :priority => 1 do
    table_for Registration.recent(20, {:certified_at => nil, :certifier_id => [nil, current_user.id]}) do
      column "" do |registration|
        link_to "certify", certify_admin_registration_path(registration)
      end
      column :id do |registration|
        link_to registration.id, admin_registration_path(registration)
      end
      column :user do |registration|
        link_to (user = registration.user).email, admin_user_path(user)
      end
      column "Created At", :created_at
      column :state do |registration|
        registration.state.name
      end
    end
  end

  section "Active Initiatives", :priority => 2 do
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

  section "Registrations Flagged for Administrative Review", :priority => 3 do
    table_for Registration.where({:needs_review => true}).limit(20).order("updated_at DESC").all do
      column :id do |registration|
        link_to registration.id, [:admin, registration]
      end
      column :email do |registration|
        link_to registration.user.email, [:admin, user]
      end
    end
  end
end
