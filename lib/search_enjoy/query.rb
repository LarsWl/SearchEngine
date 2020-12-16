# frozen_string_literal: true

module SearchEnjoy
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
    attr_reader :default_options, :query_hash

    def initialize(hash, **opts)
      @default_options = {}

      @default_options = opts

      @parent_query = nil

      @default_options[:must] ||= false
      @default_options[:inverse] ||= false

      @query_hash = to_query_hash(hash)
    end

    def to_query_hash(hash, **opts)
      result = {}

      hash.each_pair do |key, value|
        value = to_query_hash(value, opts) if value.instance_of? Hash

        result[key] = { value: value }.merge(@default_options).merge(opts)
      end

      result
    end

    def inverse!(hash = nil)
      result = {}

      hash ||= @query_hash

      hash.each_pair do |key, value|
        value = inverse(value) if value.instance_of? Hash

        result[key] = { value: value, must: !hash[:must], inverse: !hash[:inverse] }
      end

      @query_hash = result if hash == @query_hash

      result
    end

    # build_query do
    #   must(:attr1).be_in []
    #   must(:attr2).eq_to value
    #
    #   describe :attr3 do
    #     must(:key_1).be_in
    #     must.not(:key_2).eq_to value
    #   end
    # end
    def self.build_query(&block)
      query = new({})

      query.instance_eval(&block)

      query
    end

    def add_statements(&block)
      instance_eval(&block)
    end

    def must(attribute = nil)
      query = if attribute.nil?
                Query.new({}, must: true)
              else
                Query.new({attribute => nil}, must: true)
              end

      query.send('parent_query=', self)


      query
    end

    def should(attribute = nil)
      query = if attribute.nil?
                Query.new({}, must: true)
              else
                Query.new({attribute => nil}, must: true)
              end

      query.send('parent_query=', self)

      query
    end

    def not(attribute)
      @default_options[:inverse] = true

      @query_hash = to_query_hash({attribute => nil})

      self
    end

    def be(value)
      key = @query_hash.keys.first

      @query_hash[key][:value] = value

      merge_to_parent!
    end

    def describe(attribute, &block)
      query = Query.new({})

      query.instance_eval(&block)

      puts query.inspect

      @query_hash.merge!({attribute => query.query_hash})
    end

    private

    def parent_query=(query)
      @parent_query = query
    end

    def merge_to_parent!
      @parent_query.query_hash.merge!(@query_hash)
    end
  end
end
