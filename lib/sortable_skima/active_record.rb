=begin
module ActiveRecordExtension

  extend ActiveSupport::Concern

  module ClassMethods

    # @return [SQL value replacement for column]
    #Override this in active_record subclasses to costumize filters
    #example 'Aberto' --> ' status != fechado'
    #
    #This can be used for joined columns as well IE: model.joinedModel.columnName
    def sortable_custom_filters column, value
      nil
    end

    def sortable_filters column, value
      out_ar = sortable_custom_filters value, column
      if out_ar.nil? && ([value].flatten & ["Todos", "todos", "All", "all"]).empty?
        if self.column_names.include? column
          if value.kind_of?(Array) && value.length > 1
            out_ar = ["#{column} IN (?)",value]
          else
            out_ar = ["#{column} = ?",value]
          end

        end
      end
      out_ar
    end
  end
end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)#this is a fancy monkey patch as far as I care
=end