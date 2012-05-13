class RenameUserMetaToRegistration < ActiveRecord::Migration
    def self.up
        rename_table :user_meta, :registration
    end 
    def self.down
        rename_table :registration, :user_meta
    end
 end
