class RenameDriversLicenseToEncryptedDriversLicense < ActiveRecord::Migration
  def up
    rename_column :registrations, :drivers_license, :encrypted_drivers_license
  end

  def down
    rename_column :registrations, :encrypted_drivers_license, :drivers_license
  end
end
