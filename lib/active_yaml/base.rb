module ActiveYaml

  class Base < ActiveFile::Base
    class << self
      def load_file
        YAML.load_file(full_path).tap do |array_of_hashes|
          auto_assign_fields(array_of_hashes)
        end
      end

      def extension
        "yml"
      end

      def auto_assign_fields(array_of_hashes)
        array_of_hashes.inject([]) do |array, row|
          row.symbolize_keys!
          row.keys.each do |key|
            unless key.to_s == "id"
              array << key
            end
          end
          array
        end.uniq.each do |key|
          field key
        end
      end

      private :auto_assign_fields

    end
  end

end