class AddCertificationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :certification, :boolean
  end
end
