class RemoveFullnameFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :fullname
  end

  def down
    add_column :users, :fullname, :string
  end
end
