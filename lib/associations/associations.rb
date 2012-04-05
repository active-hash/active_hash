module ActiveHash
  module Associations

    module ActiveRecordExtensions

      def belongs_to_active_hash(association_id, options = {})
        options = {
          :class_name => association_id.to_s.classify,
          :foreign_key => association_id.to_s.foreign_key
        }.merge(options)

        define_method(association_id) do
          options[:class_name].constantize.find_by_id(send(options[:foreign_key]))
        end

        define_method("#{association_id}=") do |new_value|
          send "#{options[:foreign_key]}=", new_value ? new_value.id : nil
        end

        create_reflection(
            :belongs_to,
            association_id.to_sym,
            options,
            options[:class_name].constantize
            )
      end

    end

    def self.included(base)
      base.extend Methods
    end

    module Methods
      def has_many(association_id, options = {})

        define_method(association_id) do
          options = {
            :class_name => association_id.to_s.classify,
            :foreign_key => self.class.to_s.foreign_key
          }.merge(options)

          klass = options[:class_name].constantize

          if klass.respond_to?(:scoped)
            klass.scoped(:conditions => {options[:foreign_key] => id})
          else
            klass.send("find_all_by_#{options[:foreign_key]}", id)
          end
        end
      end

      def belongs_to(association_id, options = {})

        options = {
          :class_name => association_id.to_s.classify,
          :foreign_key => association_id.to_s.foreign_key
        }.merge(options)

        field options[:foreign_key].to_sym

        define_method(association_id) do
          options[:class_name].constantize.find_by_id(send(options[:foreign_key]))
        end

        define_method("#{association_id}=") do |new_value|
          attributes[options[:foreign_key].to_sym] = new_value ? new_value.id : nil
        end

      end
    end

  end
end
