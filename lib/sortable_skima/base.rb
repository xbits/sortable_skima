module SortableSkima
  class Base
    include Pagy::Backend
    class << self
      def columns
        @columns ||= {}
      end

      def filters
        @filters ||= {}
      end

      # Define a column in the table
      # @param name [Symbol] The internal name of the column
      # @param title [String] The display title for the column header
      # @param sortable [Boolean, String] True to sort by the column name, or a String for a custom SQL fragment
      def column(name, title: nil, sortable: false, &block)
        columns[name.to_sym] = {
          title: title || name.to_s.titleize,
          sortable: sortable,
          formatter: block
        }
      end

      # Define a filter for the table
      # @param name [Symbol] The param key for the filter
      # @param column [String] The SQL column to filter on (defaults to name)
      # @param collection [Array] Options for a select dropdown
      def filter(name, column: nil, collection: nil, &block)
        filters[name.to_sym] = {
          column: column || name.to_s,
          collection: collection,
          query_block: block
        }
      end
    end

    attr_reader :params, :current_user, :pagy_obj

    def initialize(params = {}, current_user = nil)
      @params = params
      @current_user = current_user
    end

    def base_query
      raise NotImplementedError, "You must define #base_query in your subclass"
    end

    def columns
      self.class.columns
    end

    def filters
      self.class.filters
    end

    def records
      return @records if defined?(@records)
      
      query = apply_sort_and_filters(base_query)
      @pagy_obj, @records = pagy(query, page: params[:page], items: params[:per_page] || 20)
      @records
    end

    def as_json(options = nil)
      SortableSkima::Serializer.new(self).as_json
    end

    private

    def apply_sort_and_filters(query)
      query = apply_filters(query)
      query = apply_sort(query)
      query
    end

    def apply_filters(query)
      filters.each do |name, config|
        val = params[:filter] && params[:filter][name.to_s]
        next if val.blank?

        if config[:query_block]
          # Allow custom proc for complex filters
          query = config[:query_block].call(query, val)
        else
          query = query.where(config[:column] => val)
        end
      end
      query
    end

    def apply_sort(query)
      sort_param = params[:sort]
      dir_param = params[:dir] == 'desc' ? 'desc' : 'asc'

      return query unless sort_param

      col_config = columns[sort_param.to_sym]
      return query unless col_config && col_config[:sortable]

      sort_sql = if col_config[:sortable].is_a?(String)
                   "#{col_config[:sortable]} #{dir_param}"
                 else
                   "#{sort_param} #{dir_param}"
                 end

      query.order(Arel.sql(sort_sql))
    end
  end
end
