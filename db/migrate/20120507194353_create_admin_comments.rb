class CreateAdminComments < ActiveRecord::Migration
  def change
    create_table :admin_comments do |t|
      t.integer :user_id
      t.text :body

      t.timestamps
    end
  end
end
