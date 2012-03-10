class CreateInitiatives < ActiveRecord::Migration
  def change
    create_table :initiatives do |t|
      t.string :name
      t.datetime :start_at
      t.text :description
      t.datetime :end_at

      t.timestamps
    end
  end
end
