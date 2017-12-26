module ActiveFile
  module MultipleFiles
    def multiple_files?
      false
    end

    def use_multiple_files
      if respond_to?(:class_attribute)
        class_attribute :filenames, instance_reader: false, instance_writer: false
      else
        class_inheritable_accessor :filenames
      end

      def self.set_filenames(*filenames)
        self.filenames = filenames
      end

      def self.multiple_files?
        true
      end

      def self.full_paths
        if filenames.present?
          filenames.collect do |filename|
            File.join(actual_root_path, "#{filename}.#{extension}")
          end
        else
          [full_path]
        end
      end
    end
  end
end
