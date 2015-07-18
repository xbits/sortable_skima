#require 'JSON'
#module SortableBacktrace
  class Backtrace < ActiveRecord::Base #TODO this should be an extension of Backtrace and not a patch I think
    belongs_to :user

    KEEP_FOR = 3.months

    def self.clear_old_records
      self.where("updated_at < #{Date.today - KEEP_FOR}").destroy_all
    end

    def self.for_token token, user
      user_id = user.id
      self.where(:action=>token,:user_id=>user_id).first || self.create(:action=>token,:user_id=>user_id)
    end

    def parsed_sortables
      if @parsed_sortables.nil?
        @parsed_sortables = JSON.parse(value || '{}')
      end
      @parsed_sortables
    end

    def get_order
      parsed_sortables['order']
    end
    def get_filters
      parsed_sortables['filters']
    end
    def get_page
      parsed_sortables['page']
    end

    def set_order new_order
      parsed_sortables['order'] = new_order
    end
    def set_filters new_filters
      parsed_sortables['filters'] = new_filters
    end
    def set_page new_page
      parsed_sortables['page'] = new_page
    end

    def update_sortables n_filters = nil , n_order = nil, n_page = nil
      set_filters n_filters unless n_filters.nil?
      set_order n_order unless n_order.nil?
      set_page n_page unless n_page.nil?
      self.update_attribute :value, parsed_sortables.to_json
    end


  end
#end