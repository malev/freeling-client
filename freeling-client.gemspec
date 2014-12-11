# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "freeling_client/version"


Gem::Specification.new do |s|
  s.name        = "freeling-client"
  s.version     = FreelingClient::VERSION
  s.date        = "2014-12-10"
  s.summary     = "Freeling client wrapper"
  s.description = "Freeling client wrapper with API"
  s.authors     = ["Marcos Vanetta"]
  s.email       = "marcosvanetta@gmail.com"
  s.homepage    = "http://codingnews.info"
  s.license       = "MIT"

  s.files       = `git ls-files -z`.split("\x0")
  s.test_files  = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency "hashie", "~> 3"
  s.add_development_dependency "bundler", "~> 1.7"
  s.add_development_dependency "rake", "~> 10.3"
  s.add_development_dependency "minitest", "~> 5"
end
