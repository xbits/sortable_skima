# SortableSkima V2

SortableSkima provides a clean, class-based DSL for building highly dynamic, sortable, and filterable tables in Rails 7+. It securely maps your view parameters to backend SQL using `Arel`, completely eliminating the need for complex string evaluations or database caching.

It is designed to be frontend-agnostic, providing built-in support for standard Rails Hotwire flows, as well as robust JSON serialization for modern Single Page Applications (React, Vue, Svelte).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sortable_skima', github: 'xbits/sortable_skima', branch: 'v2-modernization'
```

And then execute:

    $ bundle install

*(Note: V2 removes the need for any database migrations. The legacy `sortables` and `backtraces` tables are no longer required).*

## Usage: The Table Class

Create a class inheriting from `SortableSkima::Base` to define your table's data source, columns, and filters.

```ruby
# app/tables/projects_table.rb
class ProjectsTable < SortableSkima::Base
  # 1. Define the base query using standard ActiveRecord
  def base_query
    Project.left_joins(:manager).select("projects.*, users.name as manager_name")
  end

  # 2. Define Columns
  # By default, columns are not sortable. 
  # To make them sortable, map them to a safe SQL fragment.
  column :name, title: "Project Name", sortable: "projects.name"
  column :manager, title: "Manager", sortable: "users.name"
  
  # 3. Define custom formatters using blocks
  column :budget, title: "Budget", sortable: "projects.budget" do |project|
    "$#{project.budget}"
  end
  
  # 4. Define Filters
  filter :status, collection: ["Active", "Archived"]
end
```

## Controller Integration

Instantiate the table in your controller, passing in the HTTP `params`.

```ruby
class ProjectsController < ApplicationController
  def index
    @table = ProjectsTable.new(params)
    
    respond_to do |format|
      format.html # Renders standard ERB
      format.json { render json: @table.as_json } # Headless JSON API
    end
  end
end
```

## Frontend: Rails Hotwire (HTML)

Use the provided helper `skima_sort_link` to generate sorting links in your table headers. These links automatically integrate with Turbo to provide seamless updates without full page reloads.

```erb
<table>
  <thead>
    <tr>
      <th><%= skima_sort_link(@table, :name) %></th>
      <th><%= skima_sort_link(@table, :manager) %></th>
      <th><%= skima_sort_link(@table, :budget) %></th>
    </tr>
  </thead>
  <tbody>
    <% @table.records.each do |project| %>
      <tr>
        <td><%= project.name %></td>
        <td><%= project.manager_name %></td>
        <td><%= @table.columns[:budget][:formatter].call(project) %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<!-- Pagination is handled automatically via Pagy -->
<%== pagy_nav(@table.pagy_obj) %>
```

## Frontend: Single Page Applications (JSON)

If you are using a modern frontend library like React (e.g., TanStack Table) or Vue, you can fetch the `.json` endpoint. SortableSkima provides a highly structured payload:

```json
{
  "columns": [
    { "key": "name", "title": "Project Name", "sortable": true },
    { "key": "manager", "title": "Manager", "sortable": true }
  ],
  "filters": [
    { "key": "status", "options": ["Active", "Archived"] }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100,
    "per_page": 20,
    "next_page": 2,
    "prev_page": null
  },
  "data": [
    { "name": "Apollo", "manager": "John Doe", "budget": "$50000" }
  ]
}
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
