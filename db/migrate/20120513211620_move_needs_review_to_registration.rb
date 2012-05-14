class MoveNeedsReviewToRegistration < ActiveRecord::Migration
  def up
    remove_column :users, :needs_review
    add_column     :registrations, :needs_review, :boolean
  end

  def down
    remove_column :registrations, :needs_review
    add_column    :users, :needs_review, :boolean
  end
end
