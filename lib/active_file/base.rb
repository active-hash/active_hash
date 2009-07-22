module ActiveFile

  class Base < ActiveHash::Base
    class_inheritable_accessor :filename, :root_path, :cached_mtime

    class << self
      def all
        reload
        super
      end

      def reload
        if should_reload?
          self.data = load_file
        end
      end

      protected :reload

      def set_filename(name)
        write_inheritable_attribute :filename, name
      end

      protected :set_filename

      def set_root_path(path)
        write_inheritable_attribute :root_path, path
      end

      protected :set_root_path

      def load_file
        raise "Override Me"
      end

      protected :load_file

      def extension
        raise "Override Me"
      end

      protected :extension

      def full_path
        root_path = read_inheritable_attribute(:root_path)  || File.dirname(__FILE__)
        filename  = read_inheritable_attribute(:filename)   || name.tableize
        File.join(root_path, "#{filename}.#{extension}")
      end

      private :full_path

      def should_reload?
        if (mtime = File.mtime(full_path)) == read_inheritable_attribute(:cached_mtime)
          false
        else
          write_inheritable_attribute :cached_mtime, mtime
          true
        end
      end

      private :should_reload?

    end
  end

end