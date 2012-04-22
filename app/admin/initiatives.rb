ActiveAdmin.register Initiative do
  index do
    column "Name" do |initiative|
      link_to initiative.name, admin_initiative_path(initiative)
    end
    column :description
    column :created_at
    column :start_at
    column :end_at
    column :code
  end

  show :as => :block do |initiative|
    div :for => initiative do
      h2 auto_link "#{initiative.name}"
      table :class => "index_table" do
        tr do
          th do
            "Name"
          end
          th do
            "Description"
          end
          th do
            "Created At"
          end
          th do
            "Start At"
          end
          th do
            "End At"
          end
          th do
            "Code"
          end
        end
        tr do
          td do
            simple_format initiative.name
          end
          td do
            simple_format initiative.description
          end
          td do
            simple_format initiative.created_at.strftime("%B %d, %Y @ %I:%M%p")
          end
          td do
            simple_format initiative.start_at ? initiative.start_at.strftime("%B %d, %Y @ %I:%M%p") : ""
          end
          td do
            simple_format initiative.end_at ? iniatiative.end_at.strftime("%B %d, %Y @ %I:%M%p") : ""
          end
          td do
            simple_format initiative.code
          end
        end
      end
    end
  end
end
