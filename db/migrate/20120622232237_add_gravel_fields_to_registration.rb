class AddGravelFieldsToRegistration < ActiveRecord::Migration
  def change
    add_column :registrations, :drivers_license, :string
    add_column :registrations, :dob, :string
  end
end
