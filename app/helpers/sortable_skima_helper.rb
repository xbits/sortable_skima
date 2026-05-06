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
end
