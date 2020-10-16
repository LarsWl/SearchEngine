# frozen_string_literal: true

require 'rspec'
require_relative '../test_models/dummy_indexing_model'

describe 'Indexing' do
  before(:all) do
    DummyIndexingModel.recreate_index!

    class NotFound < RuntimeError; end
  end

  describe 'class methods' do
    describe '#create_index' do
      let(:new_index) { {} }
      let(:new_index_error) { 'Index already exist' }

      it 'create new index' do
        DummyIndexingModel.create_index!

        expect(DummyIndexingModel.search_index).to eq(new_index)
      end

      # it 'raise exception if index already exist' do
      #   expect do
      #     DummyIndexingModel.create_index
      #   end.to eq raise_error(IndexError, new_index_error)
    end
  end

  describe 'instance methods' do
    describe '#as_indexed_json' do
      context 'default as_indexed_json' do
        let(:test_object) do
          test_object = DummyIndexingModel.new(
            1,
            1,
            %w[test test_2],
            { key_1: '1', key_2: %w[abc cba] }
          )

          test_object
        end

        let(:expected_hash) do
          {
            attr1: test_object.attr1,
            attr2: test_object.attr2,
            attr3: test_object.attr3
          }
        end

        it 'must return expected json' do
          expect(test_object.as_indexed_json).to eq(expected_hash)
        end
      end

      context 'as_indexed_json defined explicit' do
        before do
          class DummyIndexingModelTemp < DummyIndexingModel
            def initialize(id, attr1, attr2, attr3)
              super
            end

            def as_indexed_json
              {
                attr1: attr1 * 2,
                attr2: attr2 + ['test4'],
                attr3: attr3
              }
            end
          end
        end

        let(:test_object) do
          test_object = DummyIndexingModelTemp.new(
            1,
            1,
            %w[test test_2],
            { key_1: '1', key_2: %w[abc cba] }
          )

          test_object
        end

        let(:expected_hash) do
          {
            attr1: test_object.attr1 * 2,
            attr2: test_object.attr2 << 'test4',
            attr3: test_object.attr3
          }
        end

        it 'return right json' do
          expect(test_object.as_indexed_json).to eq(expected_hash)
        end
      end
    end

    describe '#index_object' do
      let(:test_object) do
        test_object = DummyIndexingModel.new(
          1,
          1,
          %w[test test_2],
          { key_1: '1', key_2: %w[abc cba] }
        )

        test_object
      end

      let(:expected_index) do
        indexed_object = DummyIndexingModel.index_schema.call(test_object.as_indexed_json)

        {
          test_object.id => indexed_object
        }
      end

      it 'put indexed object in index' do
        test_object.index_object

        expect(DummyIndexingModel.search_index).to eq(expected_index)
      end
    end
  end
end
