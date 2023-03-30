module ActiveHash
  class Relation
    include Enumerable

    delegate :each, to: :records # Make Enumerable work
    delegate :equal?, :==, :===, :eql?, :sort!, to: :records
    delegate :empty?, :length, :first, :second, :third, :last, to: :records
    delegate :sample, to: :records

    attr_reader :conditions, :order_values, :klass, :all_records

    def initialize(klass, all_records, conditions = nil, order_values = nil)
      self.klass = klass
      self.all_records = all_records
      self.conditions = Conditions.wrap(conditions || [])
      self.order_values = order_values || []
    end

    def where(conditions_hash = :chain)
      return WhereChain.new(self) if conditions_hash == :chain

      spawn.where!(conditions_hash)
    end

    class WhereChain
      attr_reader :relation

      def initialize(relation)
        @relation = relation
      end

      def not(conditions_hash)
        relation.conditions << Condition.new(conditions_hash).invert!
        relation
      end
    end

    def order(*options)
      spawn.order!(*options)
    end

    def reorder(*options)
      spawn.reorder!(*options)
    end

    def where!(conditions_hash, inverted = false)
      self.conditions << Condition.new(conditions_hash)
      self
    end

    def invert_where
      spawn.invert_where!
    end

    def invert_where!
      conditions.map(&:invert!)
      self
    end

    def spawn
      self.class.new(klass, all_records, conditions, order_values)
    end

    def order!(*options)
      check_if_method_has_arguments!(:order, options)
      self.order_values += preprocess_order_args(options)
      self
    end

    def reorder!(*options)
      check_if_method_has_arguments!(:order, options)

      self.order_values = preprocess_order_args(options)
      @records = apply_order_values(records, order_values)

      self
    end

    def records
      @records ||= begin
        filtered_records = apply_conditions(all_records, conditions)
        ordered_records = apply_order_values(filtered_records, order_values) # rubocop:disable Lint/UselessAssignment
      end
    end

    def reload
      @records = nil # Reset records
      self
    end

    def all(options = {})
      if options.key?(:conditions)
        where(options[:conditions])
      else
        where({})
      end
    end

    def find_by(options)
      where(options).first
    end

    def find_by!(options)
      find_by(options) || (raise RecordNotFound.new("Couldn't find #{klass.name}", klass.name))
    end

    def find(id = nil, *args, &block)
      case id
        when :all
          all
        when :first
          all(*args).first
        when Array
          id.map { |i| find(i) }
        when nil
          raise RecordNotFound.new("Couldn't find #{klass.name} without an ID", klass.name, "id") unless block_given?
          records.find(&block) # delegate to Enumerable#find if a block is given
        else
          find_by_id(id) || begin
            raise RecordNotFound.new("Couldn't find #{klass.name} with ID=#{id}", klass.name, "id", id)
          end
      end
    end

    def find_by_id(id)
      index = klass.send(:record_index)[id.to_s] # TODO: Make index in Base publicly readable instead of using send?
      return unless index

      record = all_records[index]
      record if conditions.matches?(record)
    end

    def count
      length
    end

    def size
      length
    end

    def pluck(*column_names)
      symbolized_column_names = column_names.map(&:to_sym)

      if symbolized_column_names.length == 1
        column_name = symbolized_column_names.first
        all.map { |record| record[column_name] }
      else
        all.map do |record|
          symbolized_column_names.map { |column_name| record[column_name] }
        end
      end
    end

    def ids
      pluck(:id)
    end

    def pick(*column_names)
      pluck(*column_names).first
    end

    def to_ary
      records.dup
    end

    def method_missing(method_name, *args)
      return super unless klass.scopes.key?(method_name)

      instance_exec(*args, &klass.scopes[method_name])
    end

    def respond_to_missing?(method_name, include_private = false)
      klass.scopes.key?(method_name) || super
    end

    private

    attr_writer :conditions, :order_values, :klass, :all_records

    def apply_conditions(records, conditions)
      return records if conditions.blank?

      records.select do |record|
        conditions.matches?(record)
      end
    end

    def check_if_method_has_arguments!(method_name, args)
      return unless args.blank?

      raise ArgumentError,
            "The method .#{method_name}() must contain arguments."
    end

    def preprocess_order_args(order_args)
      order_args.reject!(&:blank?)
      return order_args.reverse! unless order_args.first.is_a?(String)

      ary = order_args.first.split(', ')
      ary.map! { |e| e.split(/\W+/) }.reverse!
    end

    def apply_order_values(records, args)
      ordered_records = records.dup

      args.each do |arg|
        field, dir = if arg.is_a?(Hash)
                       arg.to_a.flatten.map(&:to_sym)
                     elsif arg.is_a?(Array)
                       arg.map(&:to_sym)
                     else
                       arg.to_sym
                     end

        ordered_records.sort! do |a, b|
          if dir.present? && dir.to_sym.upcase.equal?(:DESC)
            b[field] <=> a[field]
          else
            a[field] <=> b[field]
          end
        end
      end

      ordered_records
    end
  end
end
