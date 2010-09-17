require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "active_hash"
    gem.summary = %Q{An ActiveRecord-like model that uses a hash or file as a datasource}
    gem.email = "jeff@zilkey.com"
    gem.homepage = "http://github.com/zilkey/active_hash"
    gem.authors = ["Jeff Dean", "Mike Dalessio", "Corey Innis", "Peter Jaros", "Brandon Keene", "Brian Takita", "Pat Nakajima", "John Pignata", "Michael Schubert", "Jeremy Weiskotten"]
    gem.add_dependency('activesupport', [">= 2.2.2"])
    gem.post_install_message = "NOTE:  Enums have changed to use underscores.\n\nYou may have to do a search and replace to get your suite green."
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end


task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "the-perfect-gem #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
