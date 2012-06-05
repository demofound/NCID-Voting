class AddCurrentRegistrationToUser < ActiveRecord::Migration
  def change
    add_column :users, :current_registration, :integer
  end
end
