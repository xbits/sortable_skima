module SortableSkima
  # Our host application root path
  # We set this when the engine is initialized
  mattr_accessor :app_root

  # Yield self on setup for nice config blocks
  def self.setup
    yield self
  end

  def self.root
    File.expand_path '../..', __FILE__
  end

  def self.attach_filters query, filters, srtbl
    unless filters.blank?
      filters.each_key do |filter_key|
        filter_val = filters[filter_key]
        if filter_val
          filter_obj = srtbl.filters()[filter_key.to_i]
          filter_val = filter_obj[:options][filter_val.to_i]
          unless ['Todos','todos','',"All", "all"].include?(filter_val)
            if filter_obj[:raw_sql]
              query = query.where(filter_val)
            else
              query = query.where(filter_obj[:column_name]=>filter_val)
            end

          end
        end
      end
    end
    query
  end

  def self.attach_orders query, orders, srtbl
    order_for_client = false
    orders_ar = (orders || '').split ','
    orders_ar.each do |new_order|
      order_for_client = new_order unless order_for_client != false
      new_order = new_order.split ' '
      order_by = (srtbl.columns_queries()[new_order[0].to_i][:sort_field] + " #{new_order[1]}") if new_order[0]
      if order_by
        query = query.order( order_by)
      end
    end
   return query, order_for_client
  end

  def self.attach_sortables query, sortable_id, cur_user_or_admin, include_order = false #, include_page = false
    srtbl = Sortable.find_by_id(sortable_id)

    return if srtbl.blank?

    query = eval(srtbl.base_query) if query.nil? || query == :base

    backtrace = Backtrace.for_token(srtbl.token, cur_user_or_admin)

    filters = backtrace.get_filters
    orders = backtrace.get_order
    #page = backtrace.get_page

    orders = srtbl.options[:default_order] if orders.blank?

    query = SortableSkima::attach_filters query, filters, srtbl

    query = SortableSkima::attach_orders( query, orders, srtbl) if include_order

    query
  end
  #module ActiveRecord
    # makes a Relation look like SortableSkima::Collection
  #end
end

#TODO get all these methods working in ActiveSupport so they can be used like User.sortable_shit.order(bla bla).more_sortable_shit
=begin
module Fucka
  def self.included(base)
    base.class_eval do

       # extend ActiveSupport::Concern
        def self.sortable_conds sortable_id, cur_user_or_admin, include_order = false #, include_page = false
          srtbl = Sortable.find_by_id(sortable_id)

          return if srtbl.blank?

          backtrace = Backtrace.for_token(srtbl.token, cur_user_or_admin)

          filters = backtrace.get_filters
          orders = backtrace.get_order
          page = backtrace.get_page

          orders = srtbl.options[:default_order] if orders.blank?

          query = SortableSkima::attach_filters self, filters, srtbl

          query = SortableSkima::attach_orders( self, orders, srtbl) if include_order

          puts "hello passed test #{query}"
          query
        end
      end
    end
  end

ActiveRecord::Base.send(:include, Fucka)
=end
require 'active_record'

require 'sortable_skima/backtrace.rb'
#require 'sortable_skima/active_record.rb'
require 'sortable_skima/engine.rb'
#require 'sortable_skima/action_controller.rb'
require 'sortable_skima/helpers/sortable_helper.rb'

ActionView::Base.send :include, SortableHelper
#ActionController::Base.send :include SortableControllerExtension

#ActiveSupport.on_load(:action_controller) do
 # include Foo
#end