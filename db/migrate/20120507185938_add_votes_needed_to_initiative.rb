class AddVotesNeededToInitiative < ActiveRecord::Migration
  def change
    add_column :initiatives, :votes_needed, :integer
  end
end
