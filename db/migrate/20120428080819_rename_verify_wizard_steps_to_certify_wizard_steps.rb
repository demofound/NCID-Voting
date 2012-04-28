class RenameVerifyWizardStepsToCertifyWizardSteps < ActiveRecord::Migration
  def up
    rename_table :verify_wizard_steps, :certify_wizard_steps
  end

  def down
    rename_table :certify_wizard_steps, :verify_wizard_steps
  end
end
