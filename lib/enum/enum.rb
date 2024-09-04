module ActiveHash
  module Enum

    DuplicateEnumAccessor = Class.new(RuntimeError)

    def self.included(base)
      base.extend(Methods)
    end

    module Methods

      def enum_accessor(*field_names)
        @enum_accessors = field_names
        reload
      end

      def enum(columns)
        columns.each do |column, values|
          values = values.zip(values.map(&:to_s)).to_h if values.is_a?(Array)
          values.each do |method, value|
            class_eval <<~METHOD, __FILE__, __LINE__ + 1
              # frozen_string_literal: true
              def #{method}?
                #{column} == #{value.inspect}
              end
            METHOD
          end
        end
      end

      def insert(record)
        super
        set_constant(record) if defined?(@enum_accessors)
      end

      def delete_all
        if @enum_accessors.present?
          @records.each do |record|
            constant = constant_for(record, @enum_accessors)
            remove_const(constant) if const_defined?(constant, false)
          end
        end
        super
      end

      def set_constant(record)
        constant = constant_for(record, @enum_accessors)
        return nil if constant.blank?

        unless const_defined?(constant, false)
          const_set(constant, record)
        else
          raise DuplicateEnumAccessor, "#{constant} already defined for #{self.class}" unless const_get(constant, false) == record
        end
      end

      private :set_constant

      def constant_for(record, field_names)
        field_value = field_names.map { |name| record.attributes[name] }.join("_")
        if constant = !field_value.nil? && field_value.dup
          constant.gsub!(/\W+/, "_")
          constant.gsub!(/^_|_$/, '')
          constant.upcase!
          constant
        end
      end

      private :constant_for
    end

  end

end
