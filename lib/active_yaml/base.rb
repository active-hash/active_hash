require 'yaml'

module ActiveYaml

  class Base < ActiveFile::Base
    extend ActiveFile::HashAndArrayFiles
    class << self
      def load_file
        if (data = raw_data).is_a?(Array)
          data
        elsif data.respond_to?(:values)
          data.values
        end
      end

      def extension
        "yml"
      end

      private
      def load_path(path)
        YAML.load(ERB.new(File.read(path)).result)
      end
    end
  end
end
