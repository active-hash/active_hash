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
        keys = array_of_hashes.inject(Set.new) do |keys, row|
          row.symbolize_keys!
          row.keys.each do |key|
            keys.add key unless key.to_s == "id"
          end
          keys
        end
        keys.each do |key|
          field key
        end
      end
    end
  end

end