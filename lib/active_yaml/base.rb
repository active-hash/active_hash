require 'yaml'

module ActiveYaml

  class Base < ActiveFile::Base

    extend ActiveFile::HashAndArrayFiles
    class << self
      def indifferent_access symbol_access
        # store as class instance variable so each subclass gets its own setting
        @indifferent_access = symbol_access
      end

      def load_file
        if (data = raw_data).is_a?(Array)
          data
        else
          data.values
        end
      end

      def extension
        "yml"
      end

      private

      def deep_symbolize_keys(value)
        return value.inject({}){|memo,(k,v)| memo[k.to_sym] = deep_symbolize_keys(v); memo} if value.is_a? Hash
        return value.inject([]){|memo,v    | memo           << deep_symbolize_keys(v); memo} if value.is_a? Array
        return value
      end

      def load_path(path)
        data = YAML.load_file(path)
        data = deep_symbolize_keys(data) if @indifferent_access
        data
      end
    end
  end
end
