require 'bundler'
Bundler::GemHelper.install_tasks

require 'appraisal'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end
