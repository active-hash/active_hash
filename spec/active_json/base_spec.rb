require 'spec_helper'

describe ActiveJSON::Base do

  before do
    ActiveJSON::Base.set_root_path File.expand_path(File.dirname(__FILE__) + "/../fixtures")

    class ArrayRow     < ActiveJSON::Base ; end
    class City         < ActiveJSON::Base ; end
    class State        < ActiveJSON::Base ; end
  end

  after do
    Object.send :remove_const, :ArrayRow
    Object.send :remove_const, :City
    Object.send :remove_const, :State
  end

  describe ".all" do
    context "before the file is loaded" do
      it "reads from the file" do
        State.all.should_not be_empty
        State.count.should > 0
      end
    end
  end

  describe ".where" do
    context "before the file is loaded" do
      it "reads from the file and filters by where statement" do
        State.where(:name => 'Oregon').should_not be_empty
        State.count.should > 0
      end
    end
  end

  describe ".delete_all" do
    context "when called before .all" do
      it "causes all to not load data" do
        State.delete_all
        State.all.should be_empty
      end
    end

    context "when called after .all" do
      it "clears out the data" do
        State.all.should_not be_empty
        State.delete_all
        State.all.should be_empty
      end
    end
  end

  describe ".raw_data" do
    it "returns the raw array data loaded from yaml array-formatted files" do
      ArrayRow.raw_data.should be_kind_of(Array)
    end
  end

  describe ".load_file" do
    describe "with array data" do
      it "returns an array of hashes" do
        ArrayRow.load_file.should be_kind_of(Array)
        ArrayRow.load_file.should include({"name" => "Row 1", "id" => 1})
      end
    end

    describe "with hash data" do
      it "returns an array of hashes" do
        City.load_file.should be_kind_of(Array)
        City.load_file.should include({"state" => "New York", "name" => "Albany", "id" => 1})
        City.reload
        City.all.should include(City.new(:id => 1))
      end
    end
  end

  describe 'ID finders without reliance on a call to all, even with fields specified' do

    before do
      class City < ActiveJSON::Base
        fields :id, :state, :name
      end
    end

    it 'returns a single city based on #find' do
      City.find(1).name.should == 'Albany'
    end

    it 'returns a single city based on find_by_id' do
      City.find_by_id(1).name.should == 'Albany'
    end

  end

  describe 'meta programmed finders and properties for fields that exist in the JSON file' do

    it 'should have a finder method for each property' do
      City.find_by_state('Oregon').should_not be_nil
    end

    it 'should have a find all method for each property' do
      City.find_all_by_state('Oregon').should_not be_nil
    end

  end

  describe "multiple files" do
    context "given array files" do
      before do
        class Country < ActiveJSON::Base
          use_multiple_files
          set_filenames 'countries', 'commonwealths'
        end
      end
      after { Object.send :remove_const, :Country }

      it "loads data from both files" do
        # countries.yml
        Country.find_by_name("Canada").should_not be_nil

        # commonwealths.yml
        Country.find_by_name("Puerto Rico").should_not be_nil
      end
    end

    context "given hash files" do
      before do
        class State < ActiveJSON::Base
          use_multiple_files
          set_filenames 'states', 'provences'
        end
      end

      it "loads data from both files" do
        # states.yml
        State.find_by_name("Oregon").should_not be_nil

        # provences.yml
        State.find_by_name("British Colombia").should_not be_nil
      end
    end

    context "given a hash and an array file" do
      before do
        class Municipality < ActiveJSON::Base
          use_multiple_files
          set_filenames 'states', 'countries'
        end
      end
      after { Object.send :remove_const, :Municipality }

      it "raises an exception" do
        expect do
          Municipality.find_by_name("Oregon")
        end.to raise_error(ActiveHash::FileTypeMismatchError)
      end
    end
  end
end
