# frozen_string_literal: true

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

        @search_index = {}
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
        indexed_object = self.class.index_schema.call(as_indexed_json)

        raise IndexException, 'Index doesnt exist' if self.class.search_index.nil?

        self.class.search_index[id] = indexed_object

        indexed_object
      rescue StandardError => e
        e.message
      end
    end
  end
end
