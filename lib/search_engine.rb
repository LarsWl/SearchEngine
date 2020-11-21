# frozen_string_literal: true

require_relative 'search_engine/schema'
require_relative 'search_engine/indexing'
require_relative 'search_engine/searching'
require_relative 'search_engine/aggregation'
require_relative 'search_engine/query'
require_relative  'search_engine/configuration'
require_relative 'search_engine/dumping'
require_relative 'search_engine/search_index'
require 'dry-schema'

module SearchEngine
  def self.included(base)
    base.class_eval do
      include SearchEngine::Schema
      include SearchEngine::Indexing
      include SearchEngine::Searching
      include SearchEngine::Aggregation
      include SearchEngine::Configuration
      include SearchEngine::Dumping
    end
  end
end
