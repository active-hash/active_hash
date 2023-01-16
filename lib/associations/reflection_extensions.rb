module ActiveHash
  module Reflection
    class BelongsToReflection < ActiveRecord::Reflection::BelongsToReflection
      def compute_class(name)
        if polymorphic?
          raise ArgumentError, "Polymorphic associations do not support computing the class."
        end
        
        begin
          klass = active_record.send(:compute_type, name)
        rescue NameError => error
          if error.name.match?(/(?:\A|::)#{name}\z/)
            message = "Missing model class #{name} for the #{active_record}##{self.name} association."
            message += " You can specify a different model class with the :class_name option." unless options[:class_name]
            raise NameError.new(message, name)
          else
            raise
          end
        end

        klass
      end
    end
  end
end
