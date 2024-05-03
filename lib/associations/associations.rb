module ActiveHash
  module Associations

    module ActiveRecordExtensions
      def self.extended(base)
        require_relative 'reflection_extensions'
      end

      def has_many(association_id, scope = nil, **options, &extension)
        if options[:through]
          klass_name = association_id.to_s.classify
          klass =
            begin
              klass_name.safe_constantize
            rescue StandardError, LoadError
              nil
            end

          if klass && klass < ActiveHash::Base
            define_method(association_id) do
              join_models = send(options[:through])
              join_models.flat_map do |join_model|
                join_model.send(association_id.to_s.singularize)
              end.uniq
            end

            return
          end
        end

        super
      end

      def belongs_to(name, scope = nil, **options)
        klass_name = options.key?(:class_name) ? options[:class_name] : name.to_s.camelize
        klass =
          begin
            klass_name.safe_constantize
          rescue StandardError, LoadError
            nil
          end

        if klass && klass < ActiveHash::Base
          options = { class_name: klass_name }.merge(options)
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
        options[:primary_key] ||= options[:class_name].safe_constantize.primary_key
        options[:shortcuts] = [options[:shortcuts]] unless options[:shortcuts].kind_of?(Array)

        define_method(association_id) do
          options[:class_name].safe_constantize.send("find_by_#{options[:primary_key]}", send(options[:foreign_key]))
        end

        define_method("#{association_id}=") do |new_value|
          send "#{options[:foreign_key]}=", new_value ? new_value.send(options[:primary_key]) : nil
        end

        options[:shortcuts].each do |shortcut|
          define_method("#{association_id}_#{shortcut}") do
            send(association_id).try(shortcut)
          end

          define_method("#{association_id}_#{shortcut}=") do |new_value|
            send "#{association_id}=", new_value ? options[:class_name].safe_constantize.send("find_by_#{shortcut}", new_value) : nil
          end
        end

        if ActiveRecord::Reflection.respond_to?(:create)
          if defined?(ActiveHash::Reflection::BelongsToReflection)
            reflection = ActiveHash::Reflection::BelongsToReflection.new(association_id.to_sym, nil, options, self)
          else
            reflection = ActiveRecord::Reflection.create(
              :belongs_to,
              association_id.to_sym,
              nil,
              options,
              self
            )
          end

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
              options[:class_name].safe_constantize
            )
          end
        end
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
            :foreign_key => self.class.to_s.foreign_key,
            :primary_key => self.class.primary_key
          }.merge(options)

          klass = options[:class_name].safe_constantize
          primary_key_value = send(options[:primary_key])
          foreign_key = options[:foreign_key].to_sym

          if Object.const_defined?(:ActiveRecord) && ActiveRecord.const_defined?(:Relation) && klass < ActiveRecord::Relation
            klass.where(foreign_key => primary_key_value)
          elsif klass.respond_to?(:scoped)
            klass.scoped(:conditions => {foreign_key => primary_key_value})
          else
            klass.where(foreign_key => primary_key_value)
          end
        end

        define_method("#{association_id.to_s.underscore.singularize}_ids") do
          public_send(association_id).map(&:id)
        end
      end

      def has_one(association_id, options = {})
        define_method(association_id) do
          options = {
            :class_name => association_id.to_s.classify,
            :foreign_key => self.class.to_s.foreign_key,
            :primary_key => self.class.primary_key
          }.merge(options)

          scope = options[:class_name].safe_constantize

          if scope.respond_to?(:scoped) && options[:conditions]
            scope = scope.scoped(:conditions => options[:conditions])
          end
          scope.send("find_by_#{options[:foreign_key]}", send(options[:primary_key]))
        end
      end

      def belongs_to(association_id, options = {})
        options = {
          :class_name => association_id.to_s.classify,
          :foreign_key => association_id.to_s.foreign_key,
          :primary_key => "id"
        }.merge(options)

        field options[:foreign_key].to_sym

        define_method(association_id) do
          options[:class_name].safe_constantize.send("find_by_#{options[:primary_key]}", send(options[:foreign_key]))
        end

        define_method("#{association_id}=") do |new_value|
          attributes[options[:foreign_key].to_sym] = new_value ? new_value.send(options[:primary_key]) : nil
        end
      end
    end

  end
end
