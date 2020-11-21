# frozen_string_literal: true
require 'json'

module SearchEngine
  # Module responsible for indexing elements in collection
  module Indexing
    def self.included(base)
      base.class_eval do
        include InstanceMethods
        extend ClassMethods
      end
    end

    class IndexException < RuntimeError; end

    # Class methods and variables for indexing
    module ClassMethods
      attr_accessor :search_index

      def create_index!
        raise IndexException, 'Index already exist' unless @search_index.nil?

        @search_index = SearchIndex.new(index_schema: @index_schema)
        @search_index_state = {}

        initialize_dump_counter
      rescue StandardError => e
        e.message
      end

      def delete_index!
        raise IndexException, "Index doesn't exist" if @search_index.nil?

        @search_index = nil
      rescue StandardError => e
        e.message
      end

      def recreate_index!
        delete_index!
        create_index!
      end

    end

    module InstanceMethods
      # For default execute methods with attributes name
      def as_indexed_json
        schema = self.class.index_schema

        hash = {}

        schema.key_map.each do |key|
          hash[key.name.to_sym] = send(key.name)
        end

        hash
      end

      def index_object
        raise IndexException, 'Index doesnt exist' if self.class.search_index.nil?

        indexed_object = self.class.index_schema.call(as_indexed_json)

        return if indexed_object.errors.messages.size > 0

        self.class.search_index[id.to_s.to_sym] = indexed_object

        Thread.new do
          self.class.increase_dump_counter

          self.class.dump_index_to_file if self.class.need_dump?
        end.join

        indexed_object
      rescue StandardError => e
        e.message
      end
    end
  end
end
