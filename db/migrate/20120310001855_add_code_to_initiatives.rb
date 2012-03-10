class AddCodeToInitiatives < ActiveRecord::Migration
  def change
    add_column :initiatives, :code, :string
  end
end
