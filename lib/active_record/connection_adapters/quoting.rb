module ActiveRecord
  module ConnectionAdapters
    module Quoting
      extend ActiveSupport::Concern

      module ClassMethods
        def quote_column_name(column_name)
          "'#{column_name}'"
        end
      end
    end
  end
end
