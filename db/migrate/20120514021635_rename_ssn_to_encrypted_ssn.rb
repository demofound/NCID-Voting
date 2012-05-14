class RenameSsnToEncryptedSsn < ActiveRecord::Migration
  def up
    rename_column :registrations, :ssn,            :encrypted_ssn
    rename_column :registrations, :street_address, :encrypted_street_address
  end

  def down
    rename_column :registrations, :encrypted_ssn,            :ssn
    rename_column :registrations, :encrypted_street_address, :street_address
  end
end
