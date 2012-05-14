class MoveCertificationAndLockedToRegistration < ActiveRecord::Migration
  def up
    remove_column :users, :locked
    remove_column :users, :certification
    add_column    :registrations, :locked, :boolean
    add_column    :registrations, :certification, :boolean
  end

  def down
    remove_column :registrations, :certification
    remove_column :registrations, :locked
    add_column    :users, :locked, :boolean
    add_column    :users, :certification, :boolean
  end
end
