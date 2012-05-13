class ChangeCertifiedAtToRegistrations < ActiveRecord::Migration
  def up
    remove_column :users, :certified_at
    add_column    :registration, :certified_at, :datetime
  end

  def down
    remove_column :registration, :certified_at
    add_column :users, :certified_at, :datetime
  end
end
