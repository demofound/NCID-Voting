ActiveAdmin.register State do
  actions :all, :except => [:destroy,:new]
  action_item :only => :show do
    link_to "New Certification Wizard Step", new_admin_certify_wizard_step_path
  end

  form do |f|
    f.inputs "Content" do
      f.input :required_fields, :as => :check_boxes, :collection => STATE_REQUIRED_FIELDS
    end
    f.buttons
  end

  index do
    column "Name", :sortable => :name do |state|
      link_to state.name, admin_state_path(state)
    end
  end

  show :as => :block, :title => :name do |state|
    div :for => state do
      table :class =>"index_table" do
        tr do
          th do
            "Code"
          end
          th do
            "Required Field Types"
          end
        end
        tr do
          td do
            state.code
          end
          td do
            state.required_fields.to_sentence
          end
        end
      end
      h3 "Certification Wizard Steps"
      unless steps = state.certify_wizard and steps.present?
        div do
          raw "No certification steps have been created for #{state.name}. You can #{link_to 'create a step', new_admin_certify_wizard_step_path}."
        end
      else
        table :class => "index_table" do
          tr do
            th do
              ""
            end
            th do
              "Index"
            end
            th do
              "Instructions"
            end
          end
          steps.each do |step|
            tr do
              td do
                link_to "edit", edit_admin_certify_wizard_step_path(step)
              end
              td do
                step.order_index
              end
              td do
                step.instructions
              end
            end
          end
        end
      end
    end
  end

  member_action :new_certify_wizard_step do

  end
end
