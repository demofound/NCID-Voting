class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :code
      t.string :name
      t.integer :required_fields_mask

      t.timestamps
    end
  end
end
