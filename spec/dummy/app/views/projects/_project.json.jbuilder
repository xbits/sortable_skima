json.extract! project, :id, :name, :manager_name, :budget, :status, :created_at, :updated_at
json.url project_url(project, format: :json)
