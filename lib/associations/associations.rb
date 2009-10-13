module ActiveHash
  module Associations

    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      def has_many(association_id, options = {})

        define_method(association_id) do
          options = {
            :class_name => association_id.to_s.classify,
            :foreign_key => self.class.to_s.foreign_key
          }.merge(options)

          options[:class_name].constantize.send("find_all_by_#{options[:foreign_key]}", id)
        end

      end

      def belongs_to(association_id, options = {})

        define_method(association_id) do
          options = {
            :class_name => association_id.to_s.classify,
            :foreign_key => association_id.to_s.foreign_key
          }.merge(options)

          options[:class_name].constantize.find(send(options[:foreign_key]))
        end

      end
    end
  end
end
