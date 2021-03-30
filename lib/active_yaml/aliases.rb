module ActiveYaml

  module Aliases
    def self.included(base)
      base.extend(ClassMethods)
    end

    ALIAS_KEY_REGEXP = /^\//.freeze

    module ClassMethods

      def insert(record)
        super if record.attributes.present?
      end

      def raw_data
        d = super
        if d.kind_of?(Array)
          d.reject do |h|
            h.keys.any? { |k| k.match(ALIAS_KEY_REGEXP) }
          end
        else
          d.reject do |k, v|
            v.kind_of?(Hash) && k.match(ALIAS_KEY_REGEXP)
          end
        end
      end

    end
  end

end
