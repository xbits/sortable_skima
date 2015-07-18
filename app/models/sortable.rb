class Sortable < ActiveRecord::Base
  serialize :query

   :init_query

  def base_query
    safe_query[:base_query]
  end

  def columns_queries
    safe_query[:columns_queries]
  end

  def filters
    safe_query[:filters]
  end

  def token
    safe_query[:token]
  end

  def options
    safe_query[:options]
  end

  def external_filters
    safe_query[:external_filters]
  end

  def base_query=(val)
    safe_query[:token]<<"_#{val}".hash.to_s(32)
    safe_query[:base_query] = val
  end

  def columns_queries=(val)
    safe_query[:columns_queries]=val
  end

  def filters=(val)
    safe_query[:filters]=val
  end

  def token=(val)
    safe_query[:token]=val
  end

  def options=(val)
    safe_query[:options]=val
  end

  def external_filters=(val)
    safe_query[:external_filters]=val
  end

  def add_option opt_key, opt_value
    safe_query[:token]<<"_#{opt_key} #{opt_value}".hash.to_s(32)
    safe_query[:options][opt_key] = opt_value
  end

  def add_filter new_filter
    safe_query[:token]<<"_#{new_filter[:column_name]}".hash.to_s(32)
    safe_query[:filters]<<(new_filter)
  end

  def add_column sort_field, display_method, path_method = nil
    logger.debug "ADDING COLUMN: #{sort_field}"
    display_method = sort_field if display_method.blank?
    safe_query[:columns_queries]<<{:sort_field=>sort_field,:display_method=>display_method,:path_method=>path_method}
    safe_query[:token]<<"_#{sort_field}".hash.to_s(32)
    return  safe_query[:columns_queries].size() - 1
  end

  def safe_query
    self.query = {:base_query=>'',:columns_queries=>[],:filters=>[],:token=>'',:options=>{}} if self.query.nil?
    self.query
  end

  private
  def init_query
    #query = {:base_query=>'',:columns_queries=>[]}
  end
end