module ActiveFile

  class Base < ActiveHash::Base
    class_inheritable_accessor :filename, :root_path, :cached_mtime, :reload_active_file

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

      def should_reload?
        return false if read_inheritable_attribute(:data) && ! read_inheritable_attribute(:reload_active_file)
        return false if (mtime = File.mtime(full_path)) == read_inheritable_attribute(:cached_mtime)

        write_inheritable_attribute :cached_mtime, mtime
        true
      end

      private :should_reload?

      def extension
        raise "Override Me"
      end

      protected :extension

    end
  end

end