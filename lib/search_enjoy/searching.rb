# frozen_string_literal: true

require_relative './query'

module SearchEnjoy
  module Searching
    def self.included(base)
      base.class_eval do
        # include InstanceMethods
        extend ClassMethods
      end
    end

    class Comparator
      def initialize(conditions)
        if conditions.instance_of? Query
          conditions = conditions.to_hash
        end

        @conditions = conditions
      end

      def compare(subject, conditions = @conditions)
        return false unless check_must_conditions(subject, conditions)
        return false unless check_should_conditions(subject, conditions)

        true
      end

      def check_must_conditions(subject, conditions)
        conditions.each_pair do |attr, condition|
          next unless condition[:must]

          result = check_condition(subject[attr], condition[:value])

          result = !result if condition[:inverse]

          return false unless result
        end

        true
      end

      def check_should_conditions(subject, conditions)
        conditions.each_pair do |attr, condition|
          next if condition[:must]

          result = check_condition(subject[attr], condition[:value])

          result = !result if condition[:inverse]

          return true if result
        end

        false
      end

      def check_condition(condition_subject, condition_body)
        if condition_body.instance_of? Hash
          compare(condition_subject, condition_body)
        elsif condition_body.instance_of? Array
          condition_body.include? condition_subject
        else
          condition_subject == condition_body
        end
      end
    end

    class SearchException < RuntimeError; end

    module ClassMethods
      def search(*args)
        conditions = if args.first.instance_of? Query
                       args.first.query_hash
                     else
                       Query.new({**args.first}).query_hash
                     end

        previous_result = args.last if args.last.instance_of? QueryResult

        comparator = Comparator.new(conditions)

        source = previous_result.nil? ? search_index.values : previous_result

        result = source.select { |object| comparator.compare(object) }

        QueryResult.new(self, result)
      end

      def search_not(*args)
        query = if args.first.instance_of? Query
                  args.first.inverse!
                else
                  Query.new(args.first, must: true, inverse: true)
                end

        result = search(query, args[1..])

        QueryResult.new(self, result)
      end

      def search_must(*args)
        raise SearchException, 'Forbidden use Query in search_must' if args.first.instance_of? Query

        query = Query.new(args.first, must: true)

        result = search(query, args[1..])

        QueryResult.new(self, result)
      rescue StandardError => e
        e.message
      end

      def search_must_not(*args)
        raise SearchException, 'Forbidden use Query in search_must_not' if args.first.instance_of? Query

        query = Query.new(args.first, inverse: true)

        result = search(query, args[1..])

        QueryResult.new(self, result)
      rescue StandardError => e
        e.message
      end
    end
  end
end
