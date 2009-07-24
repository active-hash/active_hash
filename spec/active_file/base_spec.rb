require 'spec/spec_helper'

describe ActiveFile::Base do
  before do
    class Country < ActiveFile::Base
    end
  end

  after do
    Object.send :remove_const, :Country
  end

  describe ".reload_active_file" do

    it "returns false by default" do
      Country.reload_active_file.should be_nil
    end

  end

  describe ".filename=" do
    before do
      Country.filename = "foo-izzle"

      class Bar < ActiveFile::Base
        self.filename = "bar-izzle"
      end
    end

    it "sets the filename on a per-subclass basis" do
      Country.filename.should == "foo-izzle"
      Bar.filename.should == "bar-izzle"
    end
  end

  describe ".set_filename" do
    before do
      Country.set_filename "foo-izzle"

      class Bar < ActiveFile::Base
        set_filename "bar-izzle"
      end
    end

    it "sets the filename on a per-subclass basis" do
      Country.filename.should == "foo-izzle"
      Bar.filename.should == "bar-izzle"
    end
  end

  describe ".root_path=" do
    before do
      Country.root_path = "foo-izzle"

      class Bar < ActiveFile::Base
        self.root_path = "bar-izzle"
      end
    end

    it "sets the root_path on a per-subclass basis" do
      Country.root_path.should == "foo-izzle"
      Bar.root_path.should == "bar-izzle"
    end
  end

  describe ".set_root_path" do
    before do
      Country.set_root_path "foo-izzle"

      class Bar < ActiveFile::Base
        set_root_path "bar-izzle"
      end
    end

    it "sets the root_path on a per-subclass basis" do
      Country.root_path.should == "foo-izzle"
      Bar.root_path.should == "bar-izzle"
    end
  end

  describe ".full_path" do
    it "defaults to the directory of the calling file" do
      class Country
        def self.extension() "foo" end
      end

      Country.full_path.should == "#{Dir.pwd}/countries.foo"
    end
  end

  describe ".all" do
    before do
      class MyClass
      end
    end

    it "loads the data from the load_file method" do
      class Country
        class << self
          def extension
            "myfile"
          end

          def load_file
            MyClass.load_file(full_path)
          end
        end
      end

      Country.reload_active_file = true
      File.stub!(:mtime).and_return(1234)
      MyClass.should_receive(:load_file).and_return([{:id => 1}, {:id => 2}, {:id => 3}])

      records = Country.all
      records.length.should == 3
      records.should =~ [Country.new(:id => 1), Country.new(:id => 2), Country.new(:id => 3)]
    end

    context "with reload=true" do
      it "does not re-fetch the data if the file's mtime has not changed" do
        class Country < ActiveFile::Base
          class << self
            def extension
              "myfile"
            end

            def load_file
              MyClass.load_file(full_path)
            end
          end
        end

        Country.reload_active_file = true
        File.stub!(:mtime).and_return(1234)
        MyClass.should_receive(:load_file).once.and_return([{:foo => :bar}])
        Country.all
        Country.all
      end

      it "does re-fetch the data if the yaml file's mtime has changed" do
        class Country < ActiveFile::Base
          class << self
            def extension
              "myfile"
            end

            def load_file
              MyClass.load_file(full_path)
            end
          end
        end

        Country.reload_active_file = true
        MyClass.should_receive(:load_file).twice.and_return([{:foo => :bar}])

        File.stub!(:mtime).and_return(1234)
        Country.all

        File.stub!(:mtime).and_return(3456)
        Country.all
      end
    end

    context "with reload=false" do
      it "does not re-fetch the data after the first call to .all" do
        class Country < ActiveFile::Base
          class << self
            def extension
              "myfile"
            end

            def load_file
              MyClass.load_file(full_path)
            end
          end
        end

        File.stub!(:mtime).once.and_return(1234)
        MyClass.should_receive(:load_file).once.and_return([{:foo => :bar}])
        Country.all

        Country.all
      end

      it "does not re-fetch the data if the yaml file's mtime has changed" do
        class Country < ActiveFile::Base
          class << self
            def extension
              "myfile"
            end

            def load_file
              MyClass.load_file(full_path)
            end
          end
        end

        MyClass.should_receive(:load_file).once.and_return([{:foo => :bar}])

        File.stub!(:mtime).and_return(1234)
        Country.all

        File.stub!(:mtime).and_return(3456)
        Country.all
      end

      it "does not fetch data if data has been set to non-nil" do
        class Country < ActiveFile::Base
          class << self
            def extension
              "myfile"
            end

            def load_file
              MyClass.load_file(full_path)
            end
          end
        end

        MyClass.should_not_receive(:load_file)
        Country.data = [{:foo => :bar}]
        Country.all
      end

      it "does not fetch data if data has been set to nil" do
        class Country < ActiveFile::Base
          class << self
            def extension
              "myfile"
            end

            def load_file
              MyClass.load_file(full_path)
            end
          end
        end

        MyClass.should_not_receive(:load_file)
        Country.data = nil
        Country.all
      end
    end
  end

end
