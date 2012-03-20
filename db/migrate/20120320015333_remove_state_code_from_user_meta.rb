class RemoveStateCodeFromUserMeta < ActiveRecord::Migration
  def up
    remove_column :user_meta, :state_code
  end

  def down
    add_column :user_meta, :state_code, :string
  end
end
