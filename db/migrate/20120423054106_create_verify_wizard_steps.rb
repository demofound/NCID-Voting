class CreateVerifyWizardSteps < ActiveRecord::Migration
  def change
    create_table :verify_wizard_steps do |t|
      t.text :instructions
      t.integer :order
      t.integer :state_id

      t.timestamps
    end
  end
end
