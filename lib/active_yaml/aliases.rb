module ActiveYaml

  module Aliases
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def insert(record)
        super if record.attributes.present?
      end

      def raw_data
        YAML.load_file(full_path).reject do |k, v|
          v.kind_of? Hash and k.match /^\//i
        end
      end

    end

    def initialize(attributes={})
      super unless attributes.keys.index { |k| k.match /^\//i }
    end
  end

end
