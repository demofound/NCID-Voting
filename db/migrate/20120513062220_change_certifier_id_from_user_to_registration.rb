class ChangeCertifierIdFromUserToRegistration < ActiveRecord::Migration
  def up
    add_column    :registration, :certifier_id, :integer
    remove_column :users,        :certifier_id
  end

  def down
    add_column    :users,        :certifier_id, :integer
    remove_column :registration, :certifier_id
  end
end
