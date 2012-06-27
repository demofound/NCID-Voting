class AddCountyToRegistration < ActiveRecord::Migration
  def change
    add_column :registrations, :county, :string
  end
end
