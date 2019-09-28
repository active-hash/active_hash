# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "active_hash/version"

Gem::Specification.new do |s|
  s.name = "active_hash"
  s.version = ActiveHash::Gem::VERSION
  s.authors = [
    "Jeff Dean",
    "Mike Dalessio",
    "Corey Innis",
    "Peter Jaros",
    "Brandon Keene",
    "Brian Takita",
    "Pat Nakajima",
    "John Pignata",
    "Michael Schubert",
    "Jeremy Weiskotten",
    "Ryan Garver",
    "Tom Stuart",
    "Joel Chippindale",
    "Kevin Olsen",
    "Vladimir Andrijevik",
    "Adam Anderson",
    "Keenan Brock",
    "Desmond Bowe",
    "Matthew O'Riordan",
    "Brett Richardson",
    "Rachel Heaton",
    "Keisuke Izumiya"
  ]
  s.email = %q{jeff@zilkey.com}
  s.summary = %q{An ActiveRecord-like model that uses a hash or file as a datasource}
  s.description = %q{Includes the ability to specify data using hashes, yml files or JSON files}
  s.homepage = %q{http://github.com/zilkey/active_hash}
  s.license = "MIT"

  s.files = [
    "CHANGELOG",
    "LICENSE",
    "README.md",
    "active_hash.gemspec",
    Dir.glob("lib/**/*")
  ].flatten
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.add_runtime_dependency('activesupport', '>= 5.0.0')
  s.add_development_dependency "pry"
  s.required_ruby_version = '>= 2.4.0'
end
