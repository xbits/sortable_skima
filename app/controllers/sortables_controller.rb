class SortablesController < ApplicationController #BaseController

  def data_query
    #puts "==================================="
    #puts "MAPPINGS: #{Devise.mappings.to_yaml}"
    #puts "====================================="
    srtbl = Sortable.find(params[:query])
    backtrace = Backtrace.for_token(srtbl.token, current_user || current_admin)

    filters = params[:filters]
    orders = params[:order_by]
    page = params[:page]
    unless srtbl.options[:disable_backtrace]
      filters = backtrace.get_filters if filters.blank?
      orders = backtrace.get_order if orders.blank?
      page = backtrace.get_page if page.blank?
    end
    orders = srtbl.options[:default_order] if orders.blank?

    backtrace.update_sortables filters, orders, page

    query = eval "#{srtbl.base_query}#{srtbl.external_filters}"

    query = SortableSkima.attach_filters query, filters, srtbl

    query, order_for_client = SortableSkima.attach_orders query, orders, srtbl

    if srtbl.options[:paginate] && page
      query = query.paginate(:page => page, :per_page => (params[:per_page] || 10))
      pag_data = view_context.will_paginate( query)
    end

    #set filters to first value if there is no backtrace
    if srtbl.options[:disable_backtrace]
      filters ||= {}
      srtbl.filters.each_index do |f_id|
        f_id_s = f_id.to_s
        filters[f_id_s] = 0 if filters[f_id_s].nil?
      end
    end

    unless query.kind_of? ActiveRecord::Relation || query.kind_of?(Array)
      query = query.all
    end

    old_json_setting = ActiveRecord::Base.include_root_in_json
    ActiveRecord::Base.include_root_in_json = false

    render :json => {:pagination=>pag_data,
                     :filters=>filters,
                     :cur_order=>order_for_client,
                     :rows_data=>query.map{|model|
                       out = {}
                        srtbl.columns_queries.each_with_index do |col,i|
                          out[i] = {:val=>model.external_eval( col[:display_method],self, view_context)} #[ef]
                          out[i][:path] = eval(col[:path_method]) if col[:path_method]
                          out[i][:field_name] = col[:sort_field]
                          out[i][:no_display] = true if col[:no_display]
                        end
                       out
                   }}
    Backtrace.clear_old_records
    ActiveRecord::Base.include_root_in_json = old_json_setting
  end



end

class ActiveRecord::Base
  def external_eval arg, controller_context, view_context
    eval arg
  end
end

