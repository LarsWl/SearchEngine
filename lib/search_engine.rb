# frozen_string_literal: true

require_relative 'search_engine/schema'
require_relative 'search_engine/indexing'
require_relative 'search_engine/searching'
require 'dry-schema'

module SearchEngine
  def self.included(base)
    base.class_eval do
      include SearchEngine::Schema
      include SearchEngine::Indexing
      include SearchEngine::Searching
    end
  end
end
