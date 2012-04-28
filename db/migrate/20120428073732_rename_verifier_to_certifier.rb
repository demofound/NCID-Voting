class RenameVerifierToCertifier < ActiveRecord::Migration
  def up
    rename_column :users, :verifier_id, :certifier_id
    rename_column :users, :verified_at, :certified_at
  end

  def down
    rename_column :users, :certifier_id, :verifier_id
    rename_column :users, :certified_at, :verified_at
  end
end
