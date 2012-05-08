class AddCommenterIdToAdminComment < ActiveRecord::Migration
  def change
    add_column :admin_comments, :commenter_id, :integer
  end
end
