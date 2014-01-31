module ActiveYaml

  class Base < ActiveFile::Base
    class << self
      def load_file
        if (data = raw_data).is_a?(Array)
          data
        else
          data.values
        end
      end

      def raw_data
        if multiple_files?
          data_from_multiple_files
        else
          YAML.load_file(full_path)
        end
      end

      def extension
        "yml"
      end

      private
      def data_from_multiple_files
        loaded_files = full_paths.collect { |path| YAML.load_file(path) }

        if loaded_files.all?{ |file_data| file_data.is_a?(Array) }
          loaded_files.sum
        elsif loaded_files.all?{ |file_data| file_data.is_a?(Hash) }
          loaded_files.inject({}) { |hash, file_data| hash.merge(file_data) }
        else
          raise ActiveHash::FileTypeMismatchError.new("Choose between hash or array syntax")
        end
      end

    end
  end

end
