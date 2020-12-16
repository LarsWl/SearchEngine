# frozen_string_literal: true

require_relative 'search_enjoy'

class DummyIndexingModel
  include SearchEnjoy

  attr_accessor :id, :attr1, :attr2, :attr3,
                :attr4, :attr5, :attr6, :attr7, :attr8

  define_json_schema do
    attr1 :integer
    attr4 :float
    attr5 :integer
    attr6 :array do
      array_type :integer
    end

    attr7 :string

    attr8 :hash do
      key_1 :integer
      key_2 :float
    end

    attr2 :array do
      array_type :string
    end

    attr3 :hash do
      hash_key :key_1, :string
      hash_key :key_2, :array do
        array_type :string
      end
    end
  end

  def initialize(id, attr1, attr2, attr3)
    @id = id
    @attr1 = attr1
    @attr2 = attr2
    @attr3 = attr3
    @attr4 = (attr1 + 2).to_f / 3
    @attr5 = attr1 * 4
    @attr6 = [attr1, @attr5, @attr5 - attr1]
    @attr7 = "test_#{@attr5}"
    @attr8 = { key_1: attr1 - 4, key_2: @attr5 * 0.22 }
  end
end

DummyIndexingModel.create_index!

test_collection = []

1.upto 1000 do |i|
  arr = [i.to_s, (i + 1).to_s, (i * 2).to_s]
  hash = { key_1: (i % 3).to_s, key_2: arr }
  test_collection << DummyIndexingModel.new(i, i % 2, arr, hash)
end

test_collection.each(&:index_object)
def test_search
  DummyIndexingModel.search
end
