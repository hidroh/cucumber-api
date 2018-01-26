# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cucumber-api/version"

Gem::Specification.new do |s|
  s.name        = "cucumber-api"
  s.version     = CucumberApi::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ha Duy Trung"]
  s.email       = ["haduytrung@gmail.com"]
  s.homepage    = "https://github.com/hidroh/cucumber-api"
  s.summary     = %q{API validator with Cucumber}
  s.description = %q{cucumber-api allows API JSON response validation and verification in BDD style.}
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 2.3.0'
  s.license     = 'Apache-2.0'

  s.add_dependency('addressable', '2.5')
  s.add_dependency('cucumber', '~> 3.1.0')
  s.add_dependency('jsonpath', '~> 0.8')
  s.add_dependency('rest-client', '~> 2.0.2')
  s.add_dependency('json-schema', '~> 2.8.0')
end
