module ActiveYaml

  class Base < ActiveFile::Base
    class << self
      def load_file
        YAML.load_file(full_path)
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
