require 'yaml'

module ActiveYaml

  class Base < ActiveFile::Base
    extend ActiveFile::HashAndArrayFiles
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
        YAML.unsafe_load(ERB.new(File.read(path)).result)
      end
else
      def load_path(path)
        YAML.load(ERB.new(File.read(path)).result)
      end
end
    end
  end
end
