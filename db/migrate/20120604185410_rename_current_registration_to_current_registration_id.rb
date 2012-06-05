class RenameCurrentRegistrationToCurrentRegistrationId < ActiveRecord::Migration
  def up
    rename_column :users, :current_registration, :current_registration_id
  end

  def down
    rename_column :users, :current_registration_id, :current_registration
  end
end
