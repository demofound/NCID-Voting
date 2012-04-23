class AddLockingAndVerificationToUser < ActiveRecord::Migration
  def change
    add_column :users, :verifier_id, :integer
    add_column :users, :locked,      :boolean
  end
end
