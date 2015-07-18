module SortableHelper

  DEFAULT_GROUP = 'default'
  @sortable_groups = {}

  def sortable_filter_tag(column_name, options_list,  opts = {})
    opts = {:raw_sql=>false, :group=>DEFAULT_GROUP}.merge(opts)

    srtbl = get_sortable opts

    sel_val = opts.delete(:selected)
    sel_val_id = nil

    opts[:class] = "#{opts[:class]} sortable-filter"
    filter_id = srtbl.filters.length
    options = []
    new_options_list = []
    options_list.each_with_index do |val,key|
      unless val.is_a?(Array)
        val = [val,val]
      end
      key_val = val[1]
      sel_val_id = options.length if( !sel_val.nil? && sel_val == key_val)
      new_options_list<<[val[0],options.length]
      options<<key_val
    end
    options_list = new_options_list

    filter = {:id=>filter_id,:column_name=>column_name,:options=>options,:raw_sql=>opts.delete(:raw_sql)}
    srtbl.add_filter filter

    opts['data-filter-key'] = filter_id
    opts['data-group-id'] = opts.delete(:group);
    name = "filters[#{column_name}]"


    option_tags = options_for_select(options_list, sel_val_id) #TODO build default list from column maybe ...IE User.all.map{username, id}
    select_tag(name, option_tags, opts)
  end


  ##
  # table options
  #   - items_per_page
  #   - disable_backtrace
  #   - group
  #   - external_filters
  #
  # col options
  #   - sort_field
  #   - display_method
  #   - path_method
  #   - title
  #   - no_display
  #   - td_class
  #   - link_item
  #   - disabled
  ##
  def sortable_table_tag base_query, columns=[], opts={}

    default_opts = {
        :default_order=>nil,
        :class =>'sortable-list',
        :items_per_page=>10,
        :disable_backtrace=>false,
        :paginate=>true,
        :group=>DEFAULT_GROUP,
        :external_filters=>nil #query conditions that should not affect the table id
    }
    opts ||= {}
    default_opts[:class] = "#{opts[:class]} #{default_opts[:class]}" #any parameter added classes plus 'sortableList'
    opts = default_opts.merge opts

    do_paginate = opts.delete(:paginate) #opts[:items_per_page]
    disable_backtrace = opts.delete(:disable_backtrace)

    srtbl = get_sortable opts
    srtbl.base_query = base_query
    srtbl.external_filters = opts.delete(:external_filters)
    srtbl.add_option :default_order, opts.delete(:default_order)
    srtbl.add_option :per_page, opts[:items_per_page] if opts[:items_per_page]
    srtbl.add_option :disable_backtrace, disable_backtrace
    srtbl.add_option :paginate, do_paginate

    out = ''
    thead = process_columns columns, srtbl
    tbody = content_tag('tbody','')
    out = ( thead + tbody).html_safe

    srtbl.save

    opts['data-sortable-query'] = srtbl.id

    opts['data-per-page'] = opts.delete(:items_per_page)
    opts['data-table-token'] = srtbl.token
    opts['data-group-id'] = opts.delete(:group)
    opts['data-initialize-on-client'] = disable_backtrace

    out = content_tag 'table', out, opts
    if do_paginate
      out += content_tag 'div','',:class=>'paginate-container','data-group-id'=>opts['data-group-id']
    end
    out
  end

  private
  def get_sortable opts
    @sortable_groups ||= {}
    srtbl = @sortable_groups[opts[:group]]
    unless srtbl
      srtbl = Sortable.new
      srtbl.token = "#{controller_name}_#{action_name}"
      @sortable_groups[opts[:group]] = srtbl
    end
    srtbl
  end

  def process_columns columns, srtbl
    num_head_rows, num_sub_cols = get_subcols_depth(columns)

    save_columns columns, srtbl
    thead = build_headers columns, num_head_rows

    content_tag('thead',thead.html_safe)
  end

  def save_columns columns, srtbl
    new_sub_cols = []
    columns.each do |col|
      sort_field =  col.delete(:sort_field)
      display_method = col.delete(:display_method) || sort_field
      col_title = (col.delete(:title) || sort_field).html_safe
      path_method = col.delete(:path_method)
      col['col-title']=col_title
      if col[:sub_columns].blank?
        col['sort-field'] = srtbl.add_column(sort_field,display_method, path_method)
        unless col[:no_display] #column is not shown on front table but is still passed to js
          col['data-class']=col.delete(:td_class)
          col['data-link-item']=col.delete(:link_item)
         end
      else
        new_sub_cols += col[:sub_columns]
      end
    end
    save_columns(new_sub_cols, srtbl) unless new_sub_cols.empty?
  end

  def build_headers columns, num_subcols
    thead = ''
    sub_cols = []
    columns.each do |col|
      col_depth = col.delete(:depth)
      if col[:sub_columns].blank?
        unless col[:no_display] #column is not shown on front table but is still passed to js
          col['rowspan'] = num_subcols if num_subcols > 1
          thead += content_tag( 'th', col['col-title'], col).html_safe
        end
      else
        new_sub_cols = col.delete :sub_columns
        master_col_opts = {'rowspan'=> num_subcols - col_depth  + 1 }.merge(col)
        thead += content_tag( 'th', col['col-title'], master_col_opts).html_safe
        sub_cols += new_sub_cols
      end

    end
    sub_head = ''
    sub_head = build_headers(sub_cols, num_subcols - 1) unless sub_cols.blank?
    content_tag('tr',thead.html_safe) + sub_head
  end

  def get_subcols_depth columns, depth = 0
    depth += 1
    num_cols = 0
    columns.each do |col|
      unless col[:sub_columns].blank?
        col_depth, num_sub_cols = get_subcols_depth(col[:sub_columns],depth)
        col[:depth] = col_depth
        col[:colspan] = num_sub_cols
        num_cols += num_sub_cols
        depth = [depth, col_depth].max
      else
        num_cols += 1
      end

    end
    return depth, num_cols
  end
end