# SortableSkima

## Description

This gem aids in building sortable and filtrable tables with both local or remote sources.

Table contents are loaded by ajax.

## Installation

Add this line to your application's Gemfile:
```ruby
    source 'http://whatever:skimaisdabomb@gems.skima.net' do
      gem "sortable_skima"
    end
```
Run:
'    $ bundle

Create both backtraces and sortables migrations if you dont have them already in your db
```ruby
    create_table :sortables do |t|
        t.text :query
        t.timestamps
    end
    create_table :backtraces do |t|
        t.integer  :user_id
        t.string   :action
        t.string   :value
        t.timestamps
    end
```

---


# Tables
## Example usage
```ruby
    <%= sortable_table_tag 'Project.select("projects.*, COUNT(warnings.id) as warnings_count").joins("LEFT JOIN users ON users.id = projects.manager_id '+
						'LEFT JOIN divisions ON divisions.id = projects.division_id '+
						'LEFT JOIN budgets ON budgets.project_id = projects.id AND budgets.active '+
                        'LEFT JOIN budget_stats ON budget_stats.budget_id = budgets.id '+
						'LEFT JOIN project_types ON project_types.id = projects.project_type_id '+
                        'LEFT JOIN warnings ON warnings.warnable_type = \'Project\' AND warnings.warnable_id = projects.id")'+
						'.joins( :project_stats).group("projects.id")',[
                   {:sort_field=>'projects.id',:title=>'Name',:display_method=>"summary",:path_method=>"project_path(model)",:td_class=>'align_center', :style=>'width: 200px;'},
                   {:sort_field=>'manager_id',:title=>'Manager',:display_method=>"manager.nil? ? '---' : manager.username",:path_method=>"model.manager.nil? ? nil : user_path(model.manager)",:td_class=>'align_center', :style=>'width: 70px;'},
                   {:sort_field=>'divisions.name',:title=>'Unit',:display_method=>'division.name rescue "---"',:td_class=>'align_center',:style=>'width: 100px;'},
                   {:sort_field=>'nature',:title=>'Nature',:display_method=>'nature',:td_class=>'align_center',:style=>'width: 70px;'},
                   {:sort_field=>'project_types.name',:title=>'Type',:display_method=>'project_type.name',:td_class=>'align_center',:style=>'width: 70px;'},
                   {:sort_field=>'status',:title=>'Status',:display_method=>'get_status',:td_class=>'align_center',:style=>'width: 70px;'},
                   {:sort_field=>'warnings_count',:title=>'Alarms',:display_method=>"warnings_count",:td_class=>'align_center',:style=>'width: 70px;'},
                   {:sort_field=>'price',:title=>'Price',:display_method=>"price",:td_class=>'align_center',:style=>'width: 70px;'},
                   {:sort_field=>'budget_stats.estimated_costs',:title=>'Est. Cost',:display_method=>"active_budget.budget_stats.estimated_costs rescue '---'",:td_class=>'align_center',:style=>'width: 70px;'},
                   {:sort_field=>'project_stats.actual_cost',:title=>'Actual Cost',:display_method=>"project_stats.actual_cost",:style=>'width: 90px;'},
                   {:sort_field=>'progress',:title=>'<small>Prog<sup>3</sup></small>',:display_method=>"100 * project_stats.progress.round(2) if !project_stats.progress.nil?",:style=>'width: 70px;'}
           ],:items_per_page=>12,
           :class=>'fixed_columns alternatingRows',
           :style => "padding-top:10px; padding-bottom:10px;" %>
```
This will render a sortable table. with the given settings.

### Method sortable_table_tag( base_query, columns=[], opts={} )

-Arguments
    -base_query
        A string containing a set of rails commands that must return an ActiveRecord::Relation.

        The query must contain a reference to any tables that will be used in either sorting or filtering either through a join() or an include().

        NOTICE: a simple 'join()' will result in an INNER JOIN exluding any unpaired results.
    -columns
        An array of hashes representing each column in the table

        The arguments for each column are:
        [:sort_field]
            The SQL field wich will be used for sorting this will be placed in the DB query
        [:title]
            The title for the html table header, can contain html, if blank the sort_field will be used
        [:display_method]
            The method to generate the content of each cell in the column, this is run in each model instance, and has controller_context and view_context available if needed
        [:path_method]
            The method used to generate an url which is then used to convert the cell into an hyperlink, run in the controller context with the variable 'model' available containing the model instance for each row
        [:no_display]
            This field wont be parsed to html.

            Useful for when extra data is needed for JS or to pass specific CSS for each row.

            NOTICE: Possible bug if the no_display columns are not added after displayed columns, untested.
        [:disabled]
            Boolean. Disables ordering on this column.
    -options
        [:default_order]
            Order to be used in case there is no order selected.
        [:items_per_page]
            For paginate. Defaults to 10.
        [:disable_backtrace]
            Boolean. Disables caching of the selected order and filters. Unstable.
        [:paginate]
            Boolean, default true. Enable pagination.
        [:group]
            String. ID of the table and filters group. For when there is more than one sortable in the same page.
        [OTHER OPTIONS]
             All options accepted for a 'content_tag' helper. EX: :class, :style , :some_attribute

---

# Filters

## Example
    Unit: <%= sortable_filter_tag  "division_id", ['All']+Division.all.map{|x|[ x.name, x.id]}, :style => "width:90px"%>
    Status: <%= sortable_filter_tag  "status", ['All']+Project::STATUSES, :style => "width:90px"%>
    Nature: <%= sortable_filter_tag "nature", ['All']+Project::TYPES, :style => "width:90px;"%>
    Type: <%= sortable_filter_tag "project_type_id", ['All']+ProjectType.all.map{|x|[ x.name, x.id]}, :style => "width:90px"%>
    Manager: <%=sortable_filter_tag("manager_id", users, :style => "width:90px") %>

### Method sortable_filter_tag(column_name, options_list,  opts = {})

[Arguments]
    [column_name]
        String with the SQL column to be used for filtering. (Discarded if :raw_sql is true)
    [options_list]
        An array with 1 or 2 dimensions .

        The first element ( ar[i][0] ) is displayed the second ( ar[i][1] ) is the actual value to be matched. ( some_query.where(column_name => option_value) )

        If it has only one dimension both values are the same.

        If :raw_sql is true then the second element should contain a valid WHERE condition. EX: 'users.login_attempts > 5'
    [opts]
        [:raw_sql]
            Boolean. Defaults to false.

            If true the value in the options list will be used literaly in the query ( some_query.where(option_value) )
        [:group]
            ID to match the one in the sortable table that is related to this filter. For when there is more than one sortable in the same page.
        [:selected]
            The selected option. Must be the same as the option value.
        [OTHER OPTIONS]
            All options that are valid for a 'select_tag' helper
---


## Frontend
This gem has Javascript and CSS files included to make the tables work on the browser

*These files are added automatically to config.default_js *

*These files must be present in your views for the frontend to work*

> skima-sortable-tables.js
> ,jquery.ba.bbq.js
> ,jquery-ui.min.js
> ,jquery-ui.css

-Events
    -sortable.loaded
        Fired after the table data has been loaded and rendered

        Arguments passed with event

        data: The data received for the table

        $table: The table element Jquery reference

        queryID: Unique identifier for the sortable query on the server

## Re-using sortable filters and orders

Catch the data loaded event in javascript
'    $('your sortable table or document or whatever').on('sortable.loaded',someFunction);
'    function someFunction(evt, data, $tableElement, queryID){
'        //Send the reference to the query to the server
'        $.ajax({
'            url:'some_path'
'            data:{sortable_id:queryID}
'        })
'    }

Then use the sortable filters in your controller
'    def some_action
'        my_base_query = User.where('some_rule')# or User or User.order_by() or SomeModel.join() or whatever
'        include_order = false
'        users = SortableSkima.attach_sortables( my_base_query,  params['sortable_id'], cur_user_or_admin, include_order)
'
'        #...do what you want with your results
'    end


    ---

