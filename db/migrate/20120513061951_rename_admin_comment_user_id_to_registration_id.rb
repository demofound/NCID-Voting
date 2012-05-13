class RenameAdminCommentUserIdToRegistrationId < ActiveRecord::Migration
  def up
    rename_column :admin_comments, :user_id, :registration_id
  end

  def down
    rename_column :admin_comments, :registration_id, :user_id
  end
end
