module ActiveJSON

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
        JSON.load(File.open(full_path, 'r:bom|utf-8'))
      end

      def extension
        "json"
      end

    end
  end

end
