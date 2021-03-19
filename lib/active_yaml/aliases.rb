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
        d = super
        if d.is_a?(Array)
          d.reject do |h|
            h.keys.any? { |k| k.match(/^\//i) }
          end
        else
          d.reject do |k, v|
            v.kind_of? Hash and k.match(/^\//i)
          end
        end
      end

    end

    def initialize(attributes={})
      super unless attributes.keys.index { |k| k.to_s.match(/^\//i) }
    end
  end

end
