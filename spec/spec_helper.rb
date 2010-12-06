require 'spec'
require 'spec/autorun'
require 'active_record'
require 'fixjour'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'active_hash'

Spec::Runner.configure do |config|
  config.include Fixjour
end
