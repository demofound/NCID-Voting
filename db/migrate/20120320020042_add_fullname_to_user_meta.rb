class AddFullnameToUserMeta < ActiveRecord::Migration
  def up
    add_column :user_meta, :fullname, :string
  end

  def down
    remove_column :user_meta, :fullname
  end
end
