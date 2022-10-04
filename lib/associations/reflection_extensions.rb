begin
  require 'active_record'
rescue LoadError
end

module ActiveHash
  module Associations
    module ReflectionExtensions
      extend ActiveSupport::Concern

      included do
        if ActiveRecord::VERSION::MAJOR >= 7
          def compute_class(name)
            super
          rescue ArgumentError => e
            if e.message =~ /Please provide the :class_name option on the association/ && klass < ActiveHash::Base
              active_record.send(:compute_type, name)
            else
              raise
            end
          end
        end
      end
    end
  end
end

if defined?(ActiveRecord::Reflection::AssociationReflection)
  ActiveRecord::Reflection::AssociationReflection.include ActiveHash::Associations::ReflectionExtensions
end
