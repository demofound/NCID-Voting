class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.boolean :decision
      t.text :comment

      t.timestamps
    end
  end
end
