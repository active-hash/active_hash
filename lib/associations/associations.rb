module ActiveHash
  module Associations
    def fetch_associations(target_model:, method: :find_by, filter:, conditions: nil)
      base = apply_scope(model: target_model, conditions: conditions)
      base.send(method, filter)
    end

    def apply_scope(model:, conditions: nil)
      if conditions && model.respond_to?(:scoped)
        model.scoped(conditions: conditions)
      else
        model
      end
    end

    module ActiveRecordExtensions
      def belongs_to(*args)
        our_args = args.dup
        options = our_args.extract_options!
        name = our_args.shift
        options = {:class_name => name.to_s.camelize }.merge(options)
        klass =
          begin
            options[:class_name].constantize
          rescue
            nil
          rescue LoadError
            nil
          end
        if klass && klass < ActiveHash::Base
          belongs_to_active_hash(name, options)
        else
          super
        end
      end

      def belongs_to_active_hash(association_id, options = {})
        options = {
          :class_name => association_id.to_s.camelize,
          :foreign_key => association_id.to_s.foreign_key,
          :shortcuts => []
        }.merge(options)
        # Define default primary_key with provided class_name if any
        options[:primary_key] ||= options[:class_name].constantize.primary_key
        options[:shortcuts] = [options[:shortcuts]] unless options[:shortcuts].kind_of?(Array)

        define_method(association_id) do
          options[:class_name].constantize.send(:find_by, options[:primary_key] => send(options[:foreign_key]))
        end

        define_method("#{association_id}=") do |new_value|
          send "#{options[:foreign_key]}=", new_value ? new_value.send(options[:primary_key]) : nil
        end

        options[:shortcuts].each do |shortcut|
          define_method("#{association_id}_#{shortcut}") do
            send(association_id).try(shortcut)
          end

          define_method("#{association_id}_#{shortcut}=") do |new_value|
            send "#{association_id}=", new_value ? options[:class_name].constantize.send("find_by_#{shortcut}", new_value) : nil
          end
        end

        if ActiveRecord::Reflection.respond_to?(:create)
          reflection = ActiveRecord::Reflection.create(
            :belongs_to,
            association_id.to_sym,
            nil,
            options,
            self
          )

          ActiveRecord::Reflection.add_reflection(
            self,
            association_id.to_sym,
            reflection
          )
        else
          method = ActiveRecord::Base.method(:create_reflection)
          if method.respond_to?(:parameters) && method.parameters.length == 5
            create_reflection(
              :belongs_to,
              association_id.to_sym,
              nil,
              options,
              self
            )
          else
            create_reflection(
              :belongs_to,
              association_id.to_sym,
              options,
              options[:class_name].constantize
            )
          end
        end
      end
    end

    def self.included(base)
      base.extend Methods
    end

    module Methods
      def association_metadata(type, association_name, options = {})
        association_names = association_name.to_s
        association_class = (options[:class_name] || association_names.classify).constantize
        {
          target_model: association_class,
          primary_key: normalize_primary_key(type, association_class),
          foreign_key: normalize_foreign_key(type, association_name, options)
        }.merge(options)
      end

      def normalize_primary_key(type, association_class)
        klass = type == :belongs_to ? association_class : name.constantize
        klass.primary_key.to_sym
      end

      def normalize_foreign_key(type, association_name, options)
        return options[:foreign_key].to_sym if options[:foreign_key]
        class_name = type == :belongs_to ? (options[:class_name] || association_name) : name
        class_name.to_s.foreign_key.to_sym
      end

      def has_many(association_name, options = {})
        meta = association_metadata(:has_many, association_name, options)

        define_method(association_name) do
          args = meta
            .slice(:target_model, :conditions)
            .merge(
              method: :where,
              filter: { meta[:foreign_key] => public_send(meta[:primary_key]) }
            )
          fetch_associations(args)
        end
      end

      def has_one(association_name, options = {})
        meta = association_metadata(:has_one, association_name , options)

        define_method(association_name) do
          args = meta
            .slice(:target_model, :conditions)
            .merge(filter: { meta[:foreign_key] => public_send(meta[:primary_key]) })
          fetch_associations(args)
        end
      end

      def belongs_to(association_name, options = {})
        meta = association_metadata(:belongs_to, association_name, options)

        field meta[:foreign_key].to_sym

        define_method(association_name) do
          args = meta
            .slice(:target_model)
            .merge(filter: { meta[:primary_key] => public_send(meta[:foreign_key]) })
          fetch_associations(args)
        end

        define_method("#{association_name}=") do |new_value|
          attributes[meta[:foreign_key].to_sym] = new_value ? new_value.send(meta[:primary_key]) : nil
        end
      end
    end
  end
end
