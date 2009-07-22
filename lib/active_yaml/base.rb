module ActiveYaml

  class Base < ActiveHash::Base
    class_inheritable_accessor :filename, :root_path

    class << self
      def set_filename(name)
        write_inheritable_attribute :filename, name
      end

      def set_root_path(path)
        write_inheritable_attribute :root_path, path
      end

      def all
        load
        super
      end

      def load
        root_path = read_inheritable_attribute(:root_path)  || File.dirname(__FILE__)
        filename  = read_inheritable_attribute(:filename)   || name.tableize
        yml = YAML.load_file(File.join(root_path, "#{filename}.yml"))
        self.data = yml
      end
    end
  end

end