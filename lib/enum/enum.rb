module ActiveHash
  module Enum

    DuplicateEnumAccessor = Class.new(RuntimeError)

    def self.included(base)
      base.extend(Methods)
    end
    
    module Methods

      def enum_accessor(field_name)
        @enum_accessor = field_name
        reload
      end

      def insert(record)
        super
        set_constant(record) if @enum_accessor.present?
      end

      def delete_all
        if @enum_accessor.present?
          @records.each do |record|
            constant = constant_for(record.attributes[@enum_accessor])
            remove_const(constant) if const_defined?(constant)
          end
        end
        super
      end

      def set_constant(record)
        constant = constant_for(record.attributes[@enum_accessor])
        return nil if constant.blank?

        unless const_defined?(constant)
          const_set(constant, record)
        else
          raise DuplicateEnumAccessor, "#{constant} already defined for #{self.class}" unless const_get(constant) == record
        end
      end

      private :set_constant

      def constant_for(field_value)
        if constant = field_value.try(:dup)
          constant.gsub!(/[^A-Za-z]*/, "") 
          constant.upcase!
          constant
        end
      end

      private :constant_for
    end

  end

end
