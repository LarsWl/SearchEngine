# frozen_string_literal: true

require 'spec_helper.rb'
require_relative '../test_models/dummy_indexing_model'

describe 'Schema' do
  before(:all) do
    class NotFound < RuntimeError; end
  end

  describe 'class_methods' do
    describe '#defining_json_schema' do
      let(:expected_schema) do
        Dry::Schema.Params do
          required(:attr1).filled(:integer)
          required(:attr2).array(:string)
          required(:attr3).hash do
            required(:key_1).filled(:string)
            required(:key_2).array(:string)
          end
        end
      end

      it 'create schema' do
        expect(DummyIndexingModel.index_schema.inspect).to eq(expected_schema.inspect)
      end
    end
  end
end
