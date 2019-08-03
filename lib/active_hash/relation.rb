module ActiveHash
  class Relation
    include Enumerable
    
    delegate :each, to: :records # Make Enumerable work
    delegate :equal?, :==, :===, :eql?, to: :records
    
    delegate_missing_to :records
    
    def initialize(klass, all_records, query_hash = nil)
      self.klass = klass
      self.all_records = all_records
      self.query_hash = query_hash
      self.records_dirty = false
      self
    end
    
    def where(query_hash = :chain)
      return ActiveHash::Base::WhereChain.new(self) if query_hash == :chain
      
      self.records_dirty = true unless query_hash.nil? || query_hash.keys.empty?
      self.query_hash.merge!(query_hash || {})
      self
    end
    
    def all(options = {})
      if options.has_key?(:conditions)
        where(options[:conditions])
      else
        where({})
      end
    end
    
    def find_by(options)
      where(options).first
    end

    def find_by!(options)
      find_by(options) || (raise RecordNotFound.new("Couldn't find #{klass.name}"))
    end
    
    def find(id, * args)
      case id
        when :all
          all
        when :first
          all(*args).first
        when Array
          id.map { |i| find(i) }
        when nil
          raise RecordNotFound.new("Couldn't find #{klass.name} without an ID")
        else
          find_by_id(id) || begin
            raise RecordNotFound.new("Couldn't find #{klass.name} with ID=#{id}")
          end
      end
    end
    
    def find_by_id(id)
      index = klass.send(:record_index)[id.to_s] # TODO: Make index in Base publicly readable instead of using send?
      index and records[index]
    end
    
    def count
      length
    end
    
    def pluck(*column_names)
      column_names.map { |column_name| all.map(&column_name.to_sym) }.inject(&:zip)
    end
    
    def reload
      @records = filter_all_records_by_query_hash
    end
    
    attr_reader :query_hash, :klass, :all_records, :records_dirty
    
    private
    
    attr_writer :query_hash, :klass, :all_records, :records_dirty
    
    def records
      if @records.nil? || records_dirty
        reload
      else
        @records
      end
    end
    
    def filter_all_records_by_query_hash
      self.records_dirty = false
      return all_records if query_hash.blank?
      
      # use index if searching by id
      if query_hash.key?(:id) || query_hash.key?("id")
        ids = (query_hash.delete(:id) || query_hash.delete("id"))
        ids = range_to_array(ids) if ids.is_a?(Range)
        candidates = Array.wrap(ids).map { |id| klass.find_by_id(id) }.compact
      end
      
      return candidates if query_hash.blank?

      (candidates || all_records || []).select do |record|
        match_options?(record, query_hash)
      end
    end
    
    def match_options?(record, options)
      options.all? do |col, match|
        if match.kind_of?(Array)
          match.any? { |v| normalize(v) == normalize(record[col]) }
        else
          normalize(record[col]) == normalize(match)
        end
      end
    end

    def normalize(v)
      v.respond_to?(:to_sym) ? v.to_sym : v
    end
    
    def range_to_array(range)
      return range.to_a unless range.end.nil?

      e = records.last[:id]
      (range.begin..e).to_a
    end
  end
end
