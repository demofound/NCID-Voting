class AddNeedsReviewToUser < ActiveRecord::Migration
  def change
    add_column :users, :needs_review, :boolean
  end
end
