module ActiveHash
  module Enum
    
    DuplicateConstant = Class.new(RuntimeError)

    def self.included(base)
      base.extend ClassMethods
    end
   
    module ClassMethods      
      def enum_accessor(field_name)
        @enum_accessor = field_name
        reload
      end

      def insert(record)
        super
        set_constant(record) if enum_accessor?
      end

      private :insert

      def set_constant(record)
        if constant = constant_for(record.attributes[@enum_accessor])
          self.const_set(constant, record)
        end
      end

      private :set_constant

      def enum_accessor?
        !@enum_accessor.nil?
      end

      private :enum_accessor?

      def constant_for(field_value)
        if constant = field_value.dup
          constant.gsub!(/[^A-Za-z]*/, "") 
          constant.upcase!
          raise DuplicateConstant, "#{constant} is already defined on #{self.class.name}" if const_defined?(constant)            
          constant
        end
      end
      
      private :constant_for
    end
    
  end
end
