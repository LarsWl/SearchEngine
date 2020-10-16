# frozen_string_literal: true

require_relative './query'

module SearchEngine
  module Searching
    def self.included(base)
      base.class_eval do
        # include InstanceMethods
        extend ClassMethods
      end
    end

    class Comparator
      def initialize(conditions)
        @conditions = conditions
      end

      def compare(subject, predicate = @conditions)
        if predicate.instance_of? Hash
          predicate.none? { |arg, value| !compare(subject[arg], value) }
        elsif predicate.instance_of? Array
          predicate.include? subject
        else
          subject == predicate
        end
      end
    end

    module ClassMethods
      def search(*args)
        previous_result = args.last if args.last.instance_of? QueryResult

        comparator = Comparator.new(args.first)

        source = previous_result.nil? ? search_index.values : previous_result

        result = source.select { |object| comparator.compare(object) }

        QueryResult.new(self, result)
      end
    end
  end
end
