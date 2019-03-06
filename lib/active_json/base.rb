module ActiveJSON
  class Base < ActiveFile::Base
    extend ActiveFile::HashAndArrayFiles
    class << self
      def load_file
        if (data = raw_data).is_a?(Array)
          data
        elsif data.respond_to?(:values)
          data.values
        end
      end

      def extension
        "json"
      end

      private
      def load_path(path)
        JSON.load(File.open(path, 'r:bom|utf-8'))
      end

    end
  end

end
