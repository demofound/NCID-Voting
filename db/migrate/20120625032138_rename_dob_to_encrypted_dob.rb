class RenameDobToEncryptedDob < ActiveRecord::Migration
  def up
    rename_column :registrations, :dob, :encrypted_dob
  end

  def down
    rename_column :registrations, :encrypted_dob, :dob
  end
end
