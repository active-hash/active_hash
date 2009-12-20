module ActiveHash
  module Associations

    def self.included(base)
      puts %Q{DEPRECATION WARNING: include #{self} should be extend #{self} and will be removed in later versions.  Called from #{caller.first}}
      base.extend self
    end

    def self.extended(base)
      base.send :extend, Methods
    end

    module Methods
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

        options = {
          :class_name => association_id.to_s.classify,
          :foreign_key => association_id.to_s.foreign_key
        }.merge(options)

        field options[:foreign_key].to_sym

        define_method(association_id) do
          options[:class_name].constantize.find_by_id(send(options[:foreign_key]))
        end

        define_method("#{association_id}=") do |new_value|
          attributes[ options[:foreign_key].to_sym ] = new_value ? new_value.id : nil
        end

      end
    end

  end
end
