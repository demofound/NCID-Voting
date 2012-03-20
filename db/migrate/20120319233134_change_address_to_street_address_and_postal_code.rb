class ChangeAddressToStreetAddressAndPostalCode < ActiveRecord::Migration
  def self.up
    add_column :user_meta, :street_address, :string
    add_column :user_meta, :city,           :string

    remove_column :user_meta, :address
  end
  def self.down
    remove_column :user_meta, :street_address
    remove_column :user_meta, :city

    add_column :user_meta, :address, :string
  end
end
