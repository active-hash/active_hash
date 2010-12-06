# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{active_hash}
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
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
    "Joel Chippindale"
  ]
  s.date = %q{2010-12-06}
  s.email = %q{jeff@zilkey.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    "CHANGELOG",
    "LICENSE",
    "README.md",
    "VERSION",
    "active_hash.gemspec",
    Dir.glob("lib/**/*")
  ].flatten
  s.homepage = %q{http://github.com/zilkey/active_hash}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{An ActiveRecord-like model that uses a hash or file as a datasource}
  s.test_files = [
    "Gemfile",
    "Gemfile.lock",
    "spec/active_file/base_spec.rb",
    "spec/active_hash/base_spec.rb",
    "spec/active_yaml/base_spec.rb",
    "spec/associations/associations_spec.rb",
    "spec/enum/enum_spec.rb",
    "spec/lint_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.2.2"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.2.2"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.2.2"])
  end
end

