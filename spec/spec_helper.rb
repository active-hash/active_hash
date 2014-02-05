require 'rspec'
require 'rspec/autorun'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'active_hash'

Dir["spec/support/**/*.rb"].each { |f|
  require File.expand_path(f)
}
