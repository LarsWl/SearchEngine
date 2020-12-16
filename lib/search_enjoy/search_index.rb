module SearchEnjoy
  class SearchIndex < Hash
    def initialize(*several_variants, index_schema: nil)
      super
      @index_schema = index_schema
    end

    class SearchIndexException < RuntimeError; end

    def to_json
      hash = {}

      each_pair do |id, object|
        object_hash = {}

        @index_schema.key_map.each do |key|
          object_hash[key.name.to_sym] = object[key.name.to_sym]
        end

        hash[id] = object_hash
      end

      JSON.generate(hash)
    rescue StandardError => e
      e.message
    end

    def load_json(json)
      hash = JSON.parse(json)
      hash.each_pair do |id, object|
        indexed_object = @index_schema.call(object)
        self[id] = indexed_object
      end
    rescue StandardError => e
      e.message
    end

  end
end