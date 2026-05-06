module SortableSkimaHelper
  # Generates a Hotwire-compatible sort link for a table column
  # @param table [SortableSkima::Base] The table instance
  # @param column_name [Symbol] The name of the column to sort
  # @param options [Hash] HTML options for the link_to tag
  def skima_sort_link(table, column_name, options = {})
    config = table.columns[column_name.to_sym]
    return config[:title] unless config && config[:sortable]
    
    current_sort = table.params[:sort].to_s == column_name.to_s
    current_dir = table.params[:dir]
    
    next_dir = if current_sort && current_dir == 'asc'
                 'desc'
               else
                 'asc'
               end

    # Build the new params for the link, preserving existing filters/page
    link_params = request.query_parameters.merge(sort: column_name, dir: next_dir)
    
    icon = if current_sort
             current_dir == 'asc' ? " &uarr;" : " &darr;"
           else
             ""
           end

    # Default to Hotwire advance to push state without full reload
    options[:data] ||= {}
    options[:data][:turbo_action] ||= "advance"

    link_to "#{config[:title]}#{icon}".html_safe, url_for(link_params), options
  end

  # Generates a select tag for a table filter
  # @param table [SortableSkima::Base] The table instance
  # @param filter_name [Symbol] The name of the filter to render
  # @param options [Hash] HTML options for the select_tag
  def skima_filter_select(table, filter_name, options = {})
    config = table.filters[filter_name.to_sym]
    return "" unless config

    # Current selected value
    selected = table.params.dig(:filter, filter_name.to_s)
    
    # Options array including a blank/all option
    choices = [["All #{filter_name.to_s.titleize}", ""]] + config[:collection].map { |c| [c, c] }

    # Generate the select input. 
    # Use onchange: "this.form.requestSubmit()" to auto-submit when using Hotwire
    options[:onchange] ||= "this.form.requestSubmit()"
    
    select_tag "filter[#{filter_name}]", options_for_select(choices, selected), options
  end
end
