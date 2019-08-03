module ActiveHash
  class ResultSet
    include Enumerable
    
    delegate :each, to: :records # Make Enumerable work
    
    delegate :first, :last, :length, to: :records
    
    def initialize(klass, all_records, query_hash = {})
      self.klass = klass
      self.all_records = all_records
      self.query_hash = query_hash
    end
    
    def where(query_hash = nil)
      return ActiveHash::Base::WhereChain.new(self.query_hash) if query_hash.nil?
      
      self.query_hash.merge!(query_hash)
      self
    end
    
    def reload
      @records = filter_all_records_by_query_hash
    end
    
    attr_accessor :query_hash, :klass, :all_records
    
    private
    
    #attr_accessor :query_hash, :klass, :all_records
    
    def records
      @records ||= filter_all_records_by_query_hash
    end
    
    def filter_all_records_by_query_hash
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

      e = data.last[:id]
      (range.begin..e).to_a
    end

  end
end
