require 'active_support'

begin
  require 'active_support/all'
rescue MissingSourceFile
end

begin
  require 'active_model'
  require 'active_model/naming'
rescue MissingSourceFile
end

require 'active_hash/base'
require 'active_file/base'
require 'active_yaml/base'
require 'associations/associations'
require 'enum/enum'
