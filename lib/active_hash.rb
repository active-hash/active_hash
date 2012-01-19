require 'active_support'

begin
  require 'active_support/core_ext'
rescue LoadError
end

begin
  require 'active_model'
  require 'active_model/naming'
rescue LoadError
end

require 'active_hash/base'
require 'active_file/base'
require 'active_yaml/base'
require 'associations/associations'
require 'enum/enum'
