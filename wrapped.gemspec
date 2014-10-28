# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "wrapped/version"

Gem::Specification.new do |s|
  s.name        = "wrapped"
  s.version     = Wrapped::VERSION
  s.authors     = ["Mike Burns"]
  s.email       = ["mike@mike-burns.com"]
  s.homepage    = "http://github.com/mike-burns/wrapped"
  s.license     = 'BSD'
  s.summary     = %q{The maybe functor for Ruby}
  s.description = %q{The unchecked nil is a dangerous concept leading to NoMethodErrors at runtime. It would be better if you were forced to explictly unwrap potentially nil values. This library provides mechanisms and convenience methods for making this more possible.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency('rspec')
  s.add_development_dependency('rake')
end
