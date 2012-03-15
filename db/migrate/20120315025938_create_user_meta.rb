class CreateUserMeta < ActiveRecord::Migration
  def change
    create_table :user_meta do |t|
      t.string :ssn
      t.string :address
      t.string :postal_code
      t.string :state_code
      t.string :country_code
      t.integer :state_id
      t.integer :user_id

      t.timestamps
    end
  end
end
