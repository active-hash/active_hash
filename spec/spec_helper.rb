require 'spec'
require 'acts_as_fu'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'active_hash'

Spec::Runner.configure do |config|
  config.include ActsAsFu
end
