class RenameUserIdToRegistrationId < ActiveRecord::Migration
  def up
    rename_column :votes, :user_id, :registration_id
  end

  def down
    rename_column :votes, :registration_id, :user_id
  end
end
