module SearchEnjoy
  module Aggregation
    def self.included(base)
      base.class_eval do
        include InstanceMethods
        extend ClassMethods
      end
    end

    module InstanceMethods

    end

    module ClassMethods
      def aggregate(*args)
        values = @search_index.values.map { |object| args.map { |key| object[key] } }
        values_per_keys = values.transpose.map(&:uniq).zip(args)

        aggregations = []

        values_per_keys.each do |key_values|
          key = key_values.last

          hash = { field: key, data: [] }

          key_values.first.each do |value|
            count = search(key => value).size

            data_hash = {
                value: value,
                count: count
            }

            hash[:data] << data_hash
          end

          aggregations << hash
        end

        aggregations
      end
    end
  end
end