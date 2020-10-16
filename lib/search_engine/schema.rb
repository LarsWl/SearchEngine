# frozen_string_literal: true

module SearchEngine
  # Module responsible for defining index schema
  module Schema
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    # class responsible for creating hash schema due to schema DSL
    class Mapping
      attr_reader :mapping

      FILLED_FIELDS = %i[
        integer
        string
        float
        date
      ].freeze

      NESTED_FIELDS = %i[array hash].freeze
      def initialize
        @mapping = {}
      end

      def respond_to_missing?; end

      private

      # @todo
      # Think about other DSL
      #
      # attr1(:array).of :integer
      # attr2(:hash).with do
      #  key(:key_1).of :integer
      # end
      def hash_key(key, value_type, &block)
        @mapping[key] = if block_given?
                          nested_mapping = Mapping.new
                          nested_mapping.instance_eval(&block)

                          nested_mapping.mapping
                        else
                          value_type
                        end
      end

      def array_type(type, &block)
        # @mapping[:array] = if block_given?
        #                     nested_mapping = Mapping.new
        #                     nested_mapping.instance_eval(&block)
        #
        #                     nested_mapping.mapping
        #                   else
        #                     type
        #                   end

        hash_key(:array, type, &block)
      end

      def method_missing(method, *args, &block)
        type = args.first

        @mapping[method] = type if FILLED_FIELDS.include? type

        if NESTED_FIELDS.include? type
          nested_mapping = Mapping.new
          nested_mapping.instance_eval(&block)

          @mapping[method] = nested_mapping.mapping
        end

        @mapping[method]
      end
    end

    # Class methods and variables
    module ClassMethods
      attr_reader :index_schema

      # define_json_schema do
      #   attr1 :value_type
      #
      #   attr2 :array do
      #     type :value_type
      #   end
      #
      #   attr3 :hash do
      #     key :key, :value_type
      #   end
      # end
      def define_json_schema(&block)
        mapping = Mapping.new

        mapping.instance_eval(&block)

        @index_schema = create_schema(mapping.mapping)
      end

      private

      # define a method for required(key) in Dry::Schema.Params
      def dry_schema_method(value)
        if value.instance_of?(Hash)
          value.key?(:array) ? :array : :hash
        elsif value.instance_of?(Symbol)
          :filled
        end
      end

      # define a arguments for required(key) in Dry::Schema.Params
      def dry_schema_args(method, value)
        if method == :filled
          value
        elsif method == :array
          value[:array].instance_of?(Hash) ? create_schema(value[:array]) : value[:array]
        elsif method == :hash
          create_schema(value)
        end
      end

      def create_schema(mapping)
        schema = self
        Dry::Schema.Params do
          mapping.each_pair do |key, value|
            method = schema.send('dry_schema_method', value)

            args = schema.send('dry_schema_args', method, value)

            required(key).send(method, args)
          end
        end
      end
    end
  end
end
