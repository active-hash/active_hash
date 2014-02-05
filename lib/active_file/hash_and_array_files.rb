module ActiveFile
  module HashAndArrayFiles
    def raw_data
      if multiple_files?
        data_from_multiple_files
      else
        load_path(full_path)
      end
    end

    private
    def data_from_multiple_files
      loaded_files = full_paths.collect { |path| load_path(path) }

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
