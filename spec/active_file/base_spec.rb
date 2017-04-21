require 'spec_helper'

describe ActiveFile::Base do
  before do
    class Country < ActiveFile::Base
    end
  end

  after do
    Object.send :remove_const, :Country
  end

  describe ".multiple_files?" do
    it "is false" do
      Country.multiple_files?.should be_falsey
    end
  end

  describe ".filename=" do
    before do
      Country.filename = "foo-izzle"

      class Bar < ActiveFile::Base
        self.filename = "bar-izzle"
      end
    end
    after { Object.send :remove_const, :Bar }

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
    after { Object.send :remove_const, :Bar }

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
    after { Object.send :remove_const, :Bar }

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
    after { Object.send :remove_const, :Bar }

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

  describe ".inherited" do
    before do
      class Country
        def self.load_file()
          {"new_york"=>{"name"=>"New York", "id"=>1}}.values
        end
      end
      Country.reload # initial load
      class SubCountry < Country; end
    end

    after { Object.send(:remove_const, :SubCountry) }

    context "when called before .all" do
      it "data_loaded is false" do
        SubCountry.data_loaded.should be_falsey
      end

      it "data is empty" do
        SubCountry.data.should_not be_empty
      end
    end

    context "when called after .all" do
      before { SubCountry.all }

      it "data_loaded is true" do
        SubCountry.data_loaded.should be_truthy
      end

      it "data isn't empty" do
        SubCountry.data.should_not be_empty
      end
    end
  end

  describe ".reload" do
    before do
      class Country
        def self.load_file()
          {"new_york"=>{"name"=>"New York", "id"=>1}}.values
        end
      end
      Country.reload # initial load
    end

    context "when nothing has been modified" do
      it "does not reload anything" do
        class Country
          def self.load_file()
            raise "should not have been called"
          end
        end
        Country.dirty.should be_falsey
        Country.reload
        Country.dirty.should be_falsey
      end
    end

    context "when forced" do
      it "reloads the data" do
        class Country
          def self.load_file()
            {"new_york"=>{"name"=>"New York", "id"=>2}}.values
          end
        end
        Country.dirty.should be_falsey
        Country.find_by_id(2).should be_nil
        Country.reload(true)
        Country.dirty.should be_falsey
        Country.find(2).name.should == "New York"
      end
    end

    context "when the data has been modified" do
      it "reloads the data" do
        Country.create!
        Country.dirty.should be_truthy
        Country.reload
        Country.dirty.should be_falsey
      end
    end
  end

end
