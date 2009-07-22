require 'spec/spec_helper'

describe ActiveFile::Base do

  describe ".filename=" do
    before do
      class Foo < ActiveFile::Base
        self.filename = "foo-izzle"
      end

      class Bar < ActiveFile::Base
        self.filename = "bar-izzle"
      end
    end

    it "sets the filename on a per-subclass basis" do
      Foo.filename.should == "foo-izzle"
      Bar.filename.should == "bar-izzle"
    end
  end

  describe ".set_filename" do
    before do
      class Foo < ActiveFile::Base
        set_filename "foo-izzle"
      end

      class Bar < ActiveFile::Base
        set_filename "bar-izzle"
      end
    end

    it "sets the filename on a per-subclass basis" do
      Foo.filename.should == "foo-izzle"
      Bar.filename.should == "bar-izzle"
    end
  end

  describe ".root_path=" do
    before do
      class Foo < ActiveFile::Base
        self.root_path = "foo-izzle"
      end

      class Bar < ActiveFile::Base
        self.root_path = "bar-izzle"
      end
    end

    it "sets the root_path on a per-subclass basis" do
      Foo.root_path.should == "foo-izzle"
      Bar.root_path.should == "bar-izzle"
    end
  end

  describe ".set_root_path" do
    before do
      class Foo < ActiveFile::Base
        set_root_path "foo-izzle"
      end

      class Bar < ActiveFile::Base
        set_root_path "bar-izzle"
      end
    end

    it "sets the root_path on a per-subclass basis" do
      Foo.root_path.should == "foo-izzle"
      Bar.root_path.should == "bar-izzle"
    end
  end

  describe ".all" do
    before do
      class MyClass
      end
    end

    it "loads the data from the load_file method" do
      class Foo01 < ActiveFile::Base
        class << self
          def extension
            "myfile"
          end

          def load_file
            MyClass.load_file(full_path)
          end
        end
      end

      File.stub!(:mtime).and_return(1234)
      MyClass.should_receive(:load_file).and_return([{:id => 1}, {:id => 2}, {:id => 3}])

      records = Foo01.all
      records.length.should == 3
      records.should =~ [Foo01.new(:id => 1), Foo01.new(:id => 2), Foo01.new(:id => 3)]
    end

    it "does not re-fetch the data if the file's mtime has not changed" do
      class SomeSampleClass < ActiveYaml::Base
        class << self
          def extension
            "myfile"
          end

          def load_file
            MyClass.load_file(full_path)
          end
        end
      end

      File.stub!(:mtime).and_return(1234)
      MyClass.should_receive(:load_file).once.and_return([{:foo => :bar}])
      SomeSampleClass.all
      SomeSampleClass.all
    end

    it "does re-fetch the data if the yaml file's mtime has changed" do
      class SomeSampleClass2 < ActiveYaml::Base
        class << self
          def extension
            "myfile"
          end

          def load_file
            MyClass.load_file(full_path)
          end
        end
      end

      MyClass.should_receive(:load_file).twice.and_return([{:foo => :bar}])

      File.stub!(:mtime).and_return(1234)
      SomeSampleClass2.all

      File.stub!(:mtime).and_return(3456)
      SomeSampleClass2.all
    end
  end

end
