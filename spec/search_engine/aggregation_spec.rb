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

      1.upto 30000 do |i|
        arr = [i.to_s, (i + 1).to_s, (i * 2).to_s]
        hash = {
            key_1: (i % 3).to_s,
            key_2: arr
        }

        @test_collection << DummyIndexingModel.new(i, i % 4, arr, hash)
      end

      @test_collection.each(&:index_object)
    end

    let(:expected_aggregation) do
      aggregation = [{ field: :attr1, data: []}]

      0.upto 3 do |i|
        hash = {
            value: i,
            count: 7500
        }

        aggregation.first[:data] << hash
      end

      aggregation
    end

    it 'make aggregations' do
      aggregation = DummyIndexingModel.aggregate(:attr1)

      puts aggregation.inspect
      puts expected_aggregation.inspect

      difference = DummyIndexingModel.aggregate(:attr1).to_a.difference(expected_aggregation)
      expect(difference).to eq([])
    end
  end
end
