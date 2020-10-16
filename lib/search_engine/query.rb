# frozen_string_literal: true

module SearchEngine
  class QueryResult < Array
    attr_writer :parent_class

    def initialize(parent_class, *args)
      super(*args)

      @parent_class = parent_class
    end

    private def method_missing(symbol, *args)
      @parent_class.send(symbol, *(args << self))
    end

    def respond_to_missing?(symbol, *_args)
      @parent_class.respond_to? symbol
    end
  end

  class Query
    class QueryStatement
      attr_accessor :subject, :condition

      def initialize(subject = nil, condition = nil)
        @subject = subject
        @condition = "subject #{condition}"
      end

      def eq_to(value)
        @condition += "==#{value}"
      end

      def be_in(value)
        @condition += " be in #{value}"
      end
    end

    attr_accessor :query_statements

    ALLOWED_FILTERS = %w[must must_not].freeze

    def initialize
      @query_statements = []
    end

    ALLOWED_FILTERS.each do |filter|
      define_method(filter) do |*args|
        query_statement = QueryStatement.new(args.first, filter)
        query_statement.subject = args.first

        @query_statements << query_statement

        query_statement
      end
    end

    def describe(attribute, &block)
      query = Query.new

      query.instance_eval(&block)

      query.query_statements.each do |statement|
        subject = "#{attribute}[#{statement.subject}]"
        @query_statements << QueryStatement.new(subject, statement.condition)
      end
    end
  end

  module InstanceMethods
    # build_query do
    #   must(:attr1).be_in []
    #   must(:attr2).eq_to value
    #
    #   describe :attr3 do
    #     must(:key_1).be_in
    #     must_not(:key_2).eq_to value
    #   end
    def build_query(&block)
      query = Query.new

      query.instance_eval(&block)

      query
    end
  end
end
