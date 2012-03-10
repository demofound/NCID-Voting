class AddUserAndInitativeToVotes < ActiveRecord::Migration
  def change
    add_column :votes, :user_id, :integer
    add_column :votes, :initiative_id, :integer
  end
end
