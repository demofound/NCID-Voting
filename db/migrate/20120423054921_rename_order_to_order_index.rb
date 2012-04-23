class RenameOrderToOrderIndex < ActiveRecord::Migration
  def up
    rename_column :verify_wizard_steps, :order, :order_index
  end

  def down
    rename_column :verify_wizard_steps, :order_index, :order
  end
end
