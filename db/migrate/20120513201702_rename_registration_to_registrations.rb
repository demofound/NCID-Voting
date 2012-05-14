class RenameRegistrationToRegistrations < ActiveRecord::Migration
  def up
    rename_table :registration, :registrations
  end

  def down
    rename_table :registrations, registration
  end
end
