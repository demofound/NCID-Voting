ActiveAdmin.register Initiative do
  index do
    column "Name" do |initiative|
      link_to initiative.name, admin_initiative_path(initiative)
    end
    column :description
    column :created_at
    column :start_at
    column :end_at
    column :code
  end

  show :as => :block do |initiative|
    div :for => initiative do
      h2 auto_link "#{initiative.name}"
      table :class => "index_table" do
        tr do
          th :colspan => 2 do
            "Name"
          end
          th do
            "Description"
          end
          th do
            "Created At"
          end
          th do
            "Start At"
          end
          th do
            "End At"
          end
          th do
            "Code"
          end
        end
        tr do
          td do
            link_to "edit", edit_admin_initiative_path(initiative)
          end
          td do
            simple_format initiative.name
          end
          td do
            simple_format initiative.description
          end
          td do
            simple_format initiative.created_at.strftime("%B %d, %Y @ %I:%M%p")
          end
          td do
            simple_format initiative.start_at ? initiative.start_at.strftime("%B %d, %Y @ %I:%M%p") : ""
          end
          td do
            simple_format initiative.end_at ? iniatiative.end_at.strftime("%B %d, %Y @ %I:%M%p") : ""
          end
          td do
            simple_format initiative.code
          end
        end
      end
    end

    h3 "Revisions"
    div :for => initiative do
      # let's frontload all the versions
      versions = initiative.versions.reverse[0..-2]

      # let's map out the IDs of the users who have participated in revisions
      user_ids = versions.map(&:whodunnit)

      # let's index the usernames by id for easy reference in our loop below
      users_by_id = User.select("username,id").all(:conditions => {:id => user_ids}).index_by(&:id)

      table :class => "versions index_table" do
        tr do
          th do
            "Revision"
          end
          th do
            "Revised At"
          end
          th do
            "User"
          end
          th do
            "Changes"
          end
        end
        # FIXME: at some point we will probably want to paginate this
        versions.each_with_index do |v,i|
          tr do
            td do
              v.index
            end
            td do
              simple_format v.created_at.strftime("%B %d, %Y @ %I:%M%p")
            end
            td do
              unless id = v.whodunnit.to_i and user = users_by_id[id]
                "no user"
              else
                link_to user.username, admin_user_path(user)
              end
            end
            td do
              last_revision = versions[i - 1] ? versions[i - 1].object : ""
              raw Diffy::Diff.new(last_revision, v.object).to_s(:html)
            end
          end
        end
      end
    end
  end
end
