module ActiveYaml

  class Base < ActiveFile::Base
    class << self
      def load_file
        if (data = raw_data).is_a?(Array)
          data
        else
          data.values
        end
      end

      def raw_data
        if multiple_files?
          full_paths.sum do |path|
            YAML.load_file(path)
          end
        else
          YAML.load_file(full_path)
        end
      end

      def extension
        "yml"
      end

    end
  end

end
