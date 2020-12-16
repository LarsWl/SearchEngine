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

      1.upto 10_000 do |i|
        arr = [i.to_s, (i + 1).to_s, (i * 2).to_s]
        hash = {
          key_1: (i % 3).to_s,
          key_2: arr
        }

        @test_collection << DummyIndexingModel.new(i, i % 2, arr, hash)
      end

      @test_collection.each(&:index_object)

      @expected_collection = @test_collection.select { |obj| obj.attr1 == 0 && obj.attr3[:key_1] == '1' }
    end

    describe '#search' do
      it 'search for query' do
        query = SearchEnjoy::Query.build_query do
          must(:attr1).be 0

          describe :attr3 do
            must(:key_1).be '1'
          end
        end

        collection = DummyIndexingModel.search(query)

        difference = collection.difference(@expected_collection)

        expect(difference).to eq([])
      end

      it '#search for args' do
        expected_collection = @test_collection.select { |obj| obj.attr1 == 0  || obj.attr3[:key_1] == '1' }.map(&:index_object)

        puts expected_collection.count

        collection = DummyIndexingModel.search(attr1: 0, attr3: { key_1: '1' })

        difference = collection.difference(expected_collection)

        expect(difference).to eq([])
      end

      it '#search for chain' do
        expected_collection = @test_collection.select { |obj| obj.attr1 == 0  || obj.attr3[:key_1] == '1' }.map(&:index_object)

        collection = DummyIndexingModel.search(attr1: 0).search( attr3: { key_1: '1' })

        difference = collection.difference(expected_collection)

        expect(difference).to eq([])
      end

      it '#search_not for args' do
        expected_collection = @test_collection.select { |obj| obj.attr1 != 0  && obj.attr3[:key_1] != '2' }.map(&:index_object)

        collection = DummyIndexingModel.search_not(attr1: 0, attr3: { key_1: '1' })

        difference = collection.difference(expected_collection)

        expect(difference).to eq([])
      end

      it '#search_not for chain' do
        expected_collection = @test_collection.select { |obj| obj.attr1 != 0  && obj.attr3[:key_1] != '2' }.map(&:index_object)

        collection = DummyIndexingModel.search_not(attr1: 0).search_not( attr3: { key_1: '1' })

        difference = collection.difference(expected_collection)

        expect(difference).to eq([])
      end

      it '#search_must for args' do
        collection = DummyIndexingModel.search_must(attr1: 0, attr3: { key_1: '1' })

        difference = collection.difference(@expected_collection)

        expect(difference).to eq([])
      end

      it '#search_must in chain' do
        collection = DummyIndexingModel.search_must(attr1: 0).search_must(attr3: { key_1: '1' })

        difference = collection.difference(@expected_collection)

        expect(difference).to eq([])
      end
    end
  end
end
