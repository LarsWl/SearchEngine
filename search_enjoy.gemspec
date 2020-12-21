# frozen_string_literal: true

require "English"
require_relative "lib/search_enjoy/version"

Gem::Specification.new do |s|
  s.name        = 'search_enjoy'
  s.version     = SearchEnjoy::VERSION
  s.date        = '2020-12-02'
  s.summary     = "Search with Enjoy!"
  s.description = "Search with Enjoy"
  s.authors     = ["Shmorgun Egor"]
  s.email       = 'egor@shmorgun.ru'
  s.homepage    = 'https://github.com/LarsWl/SearchEnjoy'
  all_files     = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.files       = all_files.grep(%r!^(exe|lib|rubocop)/|^.rubocop.yml$!)
  s.license       = 'MIT'
end

