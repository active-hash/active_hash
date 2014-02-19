require 'rspec'
require 'rspec/autorun'

SKIP_ACTIVE_RECORD = ENV['SKIP_ACTIVE_RECORD']

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'active_hash'

Dir["spec/support/**/*.rb"].each { |f|
  require File.expand_path(f)
}
