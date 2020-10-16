# frozen_string_literal: true

require 'rspec'
require_relative '../test_models/dummy_indexing_model'

describe 'Searching' do
  before(:all) do
    DummyIndexingModel.create_index!
  end

  describe 'class methods' do
    before(:all) do
      DummyIndexingModel.recreate_index!

      @test_collection = []

      1.upto 100_000 do |i|
        arr = [i.to_s, (i + 1).to_s, (i * 2).to_s]
        hash = {
          key_1: (i % 3).to_s,
          key_2: arr
        }

        @test_collection << DummyIndexingModel.new(i, i % 2, arr, hash)
      end

      @test_collection.each(&:index_object)

      @expected_collection = @test_collection.select { |obj| obj.attr1 == 0 && obj.attr3[:key_1] == '1' }
                                             .map(&:index_object)
    end

    describe '#search' do
      it 'search for query' do
      end

      it 'search for args' do
        collection = DummyIndexingModel.search(attr1: 0, attr3: { key_1: '1' })

        difference = if collection.size > @expected_collection.size
                       collection - @expected_collection
                     else
                       @expected_collection - collection
                     end

        expect(difference).to eq([])
      end

      it 'search in chain' do
        collection = DummyIndexingModel.search(attr1: 0).search(attr3: { key_1: '1' })
        difference = if collection.size > @expected_collection.size
                       collection - @expected_collection
                     else
                       @expected_collection - collection
                     end

        expect(difference).to eq([])
      end
    end
  end
end
