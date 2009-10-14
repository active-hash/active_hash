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
        YAML.load_file(full_path)
      end

      def extension
        "yml"
      end

    end
  end

end
