class AddRefCodeToVote < ActiveRecord::Migration
  def change
    add_column :votes, :ref_code, :string
  end
end
