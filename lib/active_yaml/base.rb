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
        YAML.load_file(full_path).reject do |k,v|
          v.kind_of? Hash and k.match /^\//i
        end # Reject hashes with keys starting with '/', as these are YAML aliases
      end

      def extension
        "yml"
      end

      def insert(record)
        super if record.attributes.present?
      end # Some records may have all attributes filtered out (aliases), so we ignore them
    end

    def initialize(attributes={})
      super unless attributes.keys.index{ |k| k.match /^\//i }
    end # Remove all attributes whose key starts with '/' as these are YAML aliases
  end

end
