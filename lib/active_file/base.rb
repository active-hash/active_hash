module ActiveFile

  class Base < ActiveHash::Base
    extend ActiveFile::MultipleFiles
    @@instance_lock = Mutex.new

    class_attribute :filename, :root_path, :data_loaded, instance_reader: false, instance_writer: false

    class << self

      def delete_all
        self.data_loaded = true
        super
      end

      def reload(force = false)
        @@instance_lock.synchronize do
          return if !self.dirty && !force && self.data_loaded
          self.data = load_file
          mark_clean
          self.data_loaded = true
        end
      end

      def set_filename(name)
        self.filename = name
      end

      def set_root_path(path)
        self.root_path = path
      end

      def load_file
        raise "Override Me"
      end

      def full_path
        actual_filename  = filename   || name.tableize
        File.join(actual_root_path, "#{actual_filename}.#{extension}")
      end

      def extension
        raise "Override Me"
      end
      protected :extension

      def actual_root_path
        root_path  || Dir.pwd
      end
      protected :actual_root_path

      [:find, :find_by_id, :all, :where, :method_missing].each do |method|
        define_method(method) do |*args, &block|
          reload unless data_loaded
          return super(*args, &block)
        end
      end

      def all_in_process
        return super if data_loaded
        @records || []
      end
    end
  end

end
