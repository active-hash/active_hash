require "bundler/setup"
require "pry"
require 'rspec'
require 'rspec/autorun'
require 'yaml'

SKIP_ACTIVE_RECORD = ENV['SKIP_ACTIVE_RECORD']

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'active_hash'
require 'active_record' unless SKIP_ACTIVE_RECORD

Dir["spec/support/**/*.rb"].each { |f|
  require File.expand_path(f)
}

RSpec.configure do |config|
  config.filter_run_when_matching :focus
end
