require 'spec/spec_helper'

describe ActiveYaml::Base do

  describe ".all" do
    it "loads the data from the yml file" do
      class SomeArbitraryClass < ActiveYaml::Base
        set_root_path File.dirname(__FILE__)
        set_filename "sample"
        field :name
      end

      records = SomeArbitraryClass.all
      records.length.should == 3
      records.should =~ [SomeArbitraryClass.new(:id => 1), SomeArbitraryClass.new(:id => 2), SomeArbitraryClass.new(:id => 3)]
      records.first.name.should == "US"
    end
  end

  describe "auto-discovery of fields" do
    it "dynamically creates fields for all keys in the hash" do
      class AutoDiscoverer < ActiveYaml::Base
        set_root_path File.dirname(__FILE__)
        set_filename "sample"
      end

      AutoDiscoverer.load_file

      [:name, :independence_date, :created_at, :custom_field_1, :custom_field_2, :custom_field_3].each do |field|
        AutoDiscoverer.should respond_to("find_by_#{field}")
        AutoDiscoverer.should respond_to("find_all_by_#{field}")
        AutoDiscoverer.new.should respond_to(field)
        AutoDiscoverer.new.should respond_to("#{field}?")
      end
    end

    it "doesn't override methods already defined" do
      class AlreadyDefined < ActiveYaml::Base
        set_root_path File.dirname(__FILE__)
        set_filename "sample"

        class << self
          def find_by_name(name)
            "find_by_name defined manually"
          end

          def find_all_by_name(name)
            "find_all_by_name defined manually"
          end
        end

        def name
          "name defined manually"
        end

        def name?
          "name? defined manually"
        end
      end

      AlreadyDefined.all
      AlreadyDefined.find_by_name("foo").should == "find_by_name defined manually"
      AlreadyDefined.find_all_by_name("foo").should == "find_all_by_name defined manually"
      AlreadyDefined.new.name.should == "name defined manually"
      AlreadyDefined.new.name?.should == "name? defined manually"
    end
  end

end
