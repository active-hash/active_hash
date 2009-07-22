module ActiveHash
  class Base
    class_inheritable_accessor :data
    #class_inheritable_accessor :filename
    #
    class << self

      #  def set_filename(name)
      #    self.filename = name
      #  end
      #
      #  def data_source=(yaml)
      #    @enumerated_values = nil
      #    @yaml = yaml
      #  end

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

      #  def find_by_name(name)
      #    all.detect {|record| record.name == name}
      #  end

        def find_by_id(id)
          all.detect {|record| record.id == id.to_i}
        end

      #  delegate :first, :last, :to => :all
      #
      protected

      def fields(*args)
        options = args.extract_options!
        args.each do |field|
          field(field, options)
        end
      end

      def field(field_name, options = {})
        define_getter(field_name, options[:default])
        define_interrogator(field_name)
      end

      private

      def define_getter(field, default_value)
        define_method field do
          attributes[field] || default_value
        end
      end

      def define_interrogator(field)
        define_method "#{field}?" do
          attributes[field].present?
        end
      end

      #  def data_source
      #    file_to_load = filename || File.join(RAILS_ROOT, "config/activeyaml/#{name.tableize}.yml")
      #    @yaml ||= YAML.load_file(file_to_load)
      #  end
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
