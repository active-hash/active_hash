module ActiveFile

  class Base < ActiveHash::Base
    class_inheritable_accessor :filename, :root_path, :data_loaded

    class << self

      def all
        reload unless data_loaded
        super
      end

      def delete_all
        self.data_loaded = true
        super
      end

      def reload(foo = true)
        self.data_loaded = true
        self.data = load_file
      end

      def set_filename(name)
        write_inheritable_attribute :filename, name
      end

      def set_root_path(path)
        write_inheritable_attribute :root_path, path
      end

      def load_file
        raise "Override Me"
      end

      def full_path
        root_path = read_inheritable_attribute(:root_path)  || Dir.pwd
        filename  = read_inheritable_attribute(:filename)   || name.tableize
        File.join(root_path, "#{filename}.#{extension}")
      end

      def extension
        raise "Override Me"
      end

      protected :extension

    end
  end

end
