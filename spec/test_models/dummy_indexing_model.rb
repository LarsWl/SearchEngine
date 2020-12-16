# frozen_string_literal: true

require_relative '../spec_helper'

class DummyIndexingModel
  include SearchEnjoy

  attr_accessor :id, :attr1, :attr2, :attr3

  index_configuration do |config|
    config.dump_enable = false
  end

  define_json_schema do
    id :integer

    attr1 :integer

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
  end
end
