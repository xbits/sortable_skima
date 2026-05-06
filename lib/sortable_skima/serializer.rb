module SortableSkima
  class Serializer
    attr_reader :table

    def initialize(table)
      @table = table
    end

    def as_json
      {
        columns: serialize_columns,
        filters: serialize_filters,
        pagination: serialize_pagination,
        data: serialize_data
      }
    end

    private

    def serialize_columns
      table.columns.map do |key, config|
        {
          key: key.to_s,
          title: config[:title],
          sortable: !!config[:sortable]
        }
      end
    end

    def serialize_filters
      table.filters.map do |key, config|
        {
          key: key.to_s,
          options: config[:collection] || []
        }
      end
    end

    def serialize_pagination
      pagy = table.pagy_obj
      return nil unless pagy

      {
        current_page: pagy.page,
        total_pages: pagy.pages,
        total_count: pagy.count,
        per_page: pagy.items,
        next_page: pagy.next,
        prev_page: pagy.prev
      }
    end

    def serialize_data
      table.records.map do |record|
        row = {}
        table.columns.each do |key, config|
          value = if config[:formatter]
                    config[:formatter].call(record)
                  elsif record.respond_to?(key)
                    record.public_send(key)
                  else
                    nil
                  end
          row[key] = value
        end
        row
      end
    end
  end
end
