require "bundler/setup"
require "pry"
require 'rspec'
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
  config.after(:each) do
    # To isolate tests with temporary classes.
    # ref: https://groups.google.com/g/rspec/c/7CQq0ABS3yQ
    if ActiveRecord::VERSION::MAJOR < 7
      ActiveSupport::Dependencies::Reference.clear!
    end
  end
end
