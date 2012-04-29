ActiveAdmin::Views::Pages::Show.class_eval do
  protected

  def revision_table(subject)
    h3 "Revisions"
    div :for => subject do
      # let's frontload all the versions
      versions = subject.versions.reverse[0..-2]

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
