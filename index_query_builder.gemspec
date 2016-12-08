# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'index_query_builder/version'

Gem::Specification.new do |spec|
  spec.name          = "index_query_builder"
  spec.version       = IndexQueryBuilder::VERSION
  spec.authors       = ["Arturo Pie"]
  spec.email         = ["arturop@nulogy.com"]
  spec.summary       = %q{DSL for getting data for index pages.}
  spec.description   = %q{This gem provides a DSL on top of ActiveRecord to get collection of models for index pages with filters.}
  spec.homepage      = ""

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_development_dependency "rspec", "~> 3.3.0"

  spec.add_development_dependency "activerecord", "~> 4.0.0"
  spec.add_development_dependency "activesupport", "~> 4.0.0"

  spec.add_development_dependency "pg", "~> 0.18.1"
end
