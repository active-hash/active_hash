require 'active_support'

begin
  require 'active_support/core_ext'
rescue
end

begin
  require 'active_model'
  require 'active_model/naming'
rescue LoadError
end

require 'active_hash/base'
require 'active_hash/relation'
require 'active_file/multiple_files'
require 'active_file/hash_and_array_files'
require 'active_file/base'
require 'active_yaml/base'
require 'active_yaml/aliases'
require 'active_json/base'
require 'associations/associations'
require 'enum/enum'
