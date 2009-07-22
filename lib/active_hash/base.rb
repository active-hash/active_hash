module ActiveHash
  class Base
    class_inheritable_accessor :data
    class << self

      def data=(array_of_hashes)
        @records = nil
        write_inheritable_attribute(:data, array_of_hashes)
      end

      def all
        @records ||= read_inheritable_attribute(:data).collect {|hash| new(hash)}
      end

      def count
        all.length
      end

      def find(id, *args)
        case id
          when :all
            all
          when Array
            all.select {|record| id.map(&:to_i).include?(record.id) }
          else
            find_by_id(id)
        end
      end

      def find_by_id(id)
        all.detect {|record| record.id == id.to_i}
      end

      delegate :first, :last, :to => :all

      def fields(*args)
        options = args.extract_options!
        args.each do |field|
          field(field, options)
        end
      end

      def field(field_name, options = {})
        define_getter_method(field_name, options[:default])
        define_interrogator_method(field_name)
        define_custom_find_method(field_name)
        define_custom_find_all_method(field_name)
      end

      def define_getter_method(field, default_value)
        define_method field do
          attributes[field] || default_value
        end
      end

      private :define_getter_method

      def define_interrogator_method(field)
        define_method "#{field}?" do
          attributes[field].present?
        end
      end

      private :define_interrogator_method

      def define_custom_find_method(field_name)
        meta_class.instance_eval do
          define_method "find_by_#{field_name}" do |name|
            all.detect {|record| record.send(field_name) == name }
          end
        end
      end

      private :define_custom_find_method

      def define_custom_find_all_method(field_name)
        meta_class.instance_eval do
          define_method "find_all_by_#{field_name}" do |name|
            all.select {|record| record.send(field_name) == name }
          end
        end
      end

      private :define_custom_find_all_method


      def meta_class
        class << self
          self
        end
      end

      private :meta_class

    end

    attr_reader :attributes

    def initialize(options = {})
      options.symbolize_keys!
      @attributes = options
    end

    def id
      attributes[:id] ? attributes[:id].to_i : nil
    end

    alias quoted_id id

    def new_record?
      false
    end

    def readonly?
      true
    end

    def to_param
      id.to_s
    end

    def eql?(other)
      other.instance_of?(self.class) and not id.nil? and (id == other.id)
    end

    alias == eql?

    def hash
      id.hash
    end

  end
end
