require 'spec/spec_helper'

describe ActiveYaml::Base do

  before do
    class Country < ActiveYaml::Base
    end
  end

  describe ".filename=" do
    before do
      class Foo < ActiveYaml::Base
        self.filename = "foo-izzle"
      end

      class Bar < ActiveYaml::Base
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
      class Foo < ActiveYaml::Base
        set_filename "foo-izzle"
      end

      class Bar < ActiveYaml::Base
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
      class Foo < ActiveYaml::Base
        self.root_path = "foo-izzle"
      end

      class Bar < ActiveYaml::Base
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
      class Foo < ActiveYaml::Base
        set_root_path "foo-izzle"
      end

      class Bar < ActiveYaml::Base
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
      class Foo < ActiveYaml::Base
        set_root_path File.dirname(__FILE__)
        set_filename "sample"
        field :name
      end
    end

    it "loads the data from the yml file" do
      records = Foo.all
      records.length.should == 2
      records.should =~ [Foo.new(:id => 1), Foo.new(:id => 2)]
      records.first.name.should == "US"
    end
  end
end
