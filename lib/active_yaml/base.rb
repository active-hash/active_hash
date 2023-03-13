require 'yaml'

module ActiveYaml

  class Base < ActiveFile::Base
    extend ActiveFile::HashAndArrayFiles

    cattr_accessor :process_erb, instance_accessor: false
    @@process_erb = true

    class << self
      def load_file
        if (data = raw_data).is_a?(Array)
          data
        elsif data.respond_to?(:values)
          data.map{ |key, value| {"key" => key}.merge(value) }
        end
      end

      def extension
        "yml"
      end

      private
if Psych::VERSION >= "4.0.0"
      def load_path(path)
        result = File.read(path)
        result = ERB.new(result).result if process_erb
        YAML.unsafe_load(result)
      end
else
      def load_path(path)
        result = File.read(path)
        result = ERB.new(result).result if process_erb
        YAML.load(result)
      end
end
    end
  end
end
