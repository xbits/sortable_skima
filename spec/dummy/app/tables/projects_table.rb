class ProjectsTable < SortableSkima::Base
  def base_query
    Project.all
  end

  column :name, title: "Project Name", sortable: "name"
  column :manager_name, title: "Manager", sortable: "manager_name"
  
  column :budget, title: "Budget", sortable: "budget" do |project|
    ActionController::Base.helpers.number_to_currency(project.budget)
  end

  column :status, title: "Status", sortable: "status"

  filter :status, collection: ["Active", "Archived"]
end
