# frozen_string_literal: true

require_relative 'search_enjoy/schema'
require_relative 'search_enjoy/indexing'
require_relative 'search_enjoy/searching'
require_relative 'search_enjoy/aggregation'
require_relative 'search_enjoy/query'
require_relative 'search_enjoy/configuration'
require_relative 'search_enjoy/dumping'
require_relative 'search_enjoy/search_index'
require 'dry-schema'

module SearchEnjoy
  def self.included(base)
    base.class_eval do
      include SearchEnjoy::Schema
      include SearchEnjoy::Indexing
      include SearchEnjoy::Searching
      include SearchEnjoy::Aggregation
      include SearchEnjoy::Configuration
      include SearchEnjoy::Dumping
    end
  end
end
