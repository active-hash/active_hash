require 'spec_helper'

describe ActiveJSON::Base do

  before do
    ActiveJSON::Base.set_root_path File.expand_path(File.dirname(__FILE__) + "/../fixtures")

    class ArrayRow < ActiveJSON::Base; end
    class City < ActiveJSON::Base; end
    class State < ActiveJSON::Base; end
    class Empty < ActiveJSON::Base ; end # Empty JSON
  end

  after do
    Object.send :remove_const, :ArrayRow
    Object.send :remove_const, :City
    Object.send :remove_const, :State
    Object.send :remove_const, :Empty
  end

  describe ".load_path" do
    it 'can execute embedded ruby' do
       expect(State.first.name).to match(/^New York/)
    end

    it 'can load empty yaml' do
      expect(Empty.first).to be_nil
    end
  end

  describe ".all" do
    context "before the file is loaded" do
      it "reads from the file" do
        expect(State.all).not_to be_empty
        expect(State.count).to be > 0
      end
    end
  end

  describe ".where" do
    context "before the file is loaded" do
      it "reads from the file and filters by where statement" do
        expect(State.where(:name => 'Oregon')).not_to be_empty
        expect(State.count).to be > 0
      end
    end
  end

  describe ".delete_all" do
    context "when called before .all" do
      it "causes all to not load data" do
        State.delete_all
        expect(State.all).to be_empty
      end
    end

    context "when called after .all" do
      it "clears out the data" do
        expect(State.all).not_to be_empty
        State.delete_all
        expect(State.all).to be_empty
      end
    end
  end

  describe ".raw_data" do
    it "returns the raw array data loaded from yaml array-formatted files" do
      expect(ArrayRow.raw_data).to be_kind_of(Array)
    end
  end

  describe ".load_file" do
    describe "with array data" do
      it "returns an array of hashes" do
        expect(ArrayRow.load_file).to be_kind_of(Array)
        expect(ArrayRow.load_file).to include({"name" => "Row 1", "id" => 1})
      end
    end

    describe "with hash data" do
      it "returns an array of hashes" do
        expect(City.load_file).to be_kind_of(Array)
        expect(City.load_file).to include({"state" => "New York", "name" => "Albany", "id" => 1})
        City.reload
        expect(City.all).to include(City.new(:id => 1))
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
      expect(City.find(1).name).to eq('Albany')
    end

    it 'returns a single city based on find_by_id' do
      expect(City.find_by_id(1).name).to eq('Albany')
    end

  end

  describe 'meta programmed finders and properties for fields that exist in the JSON file' do

    it 'should have a finder method for each property' do
      expect(City.find_by_state('Oregon')).not_to be_nil
    end

    it 'should have a find all method for each property' do
      expect(City.find_all_by_state('Oregon')).not_to be_nil
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
        expect(Country.find_by_name("Canada")).not_to be_nil

        # commonwealths.yml
        expect(Country.find_by_name("Puerto Rico")).not_to be_nil
      end
    end

    context "given hash files" do
      before do
        class MultiState < ActiveJSON::Base
          use_multiple_files
          set_filenames 'states', 'provinces'
        end
      end

      after do
        Object.send(:remove_const, :MultiState)
      end

      it "loads data from both files" do
        # states.yml
        expect(MultiState.find_by_name("Oregon")).not_to be_nil

        # provinces.yml
        expect(MultiState.find_by_name("British Colombia")).not_to be_nil
      end
    end

    context "given a hash and an array file" do
      before do
        class Municipality < ActiveJSON::Base
          use_multiple_files
          set_filenames 'states', 'countries'
        end
      end
      after { Object.send(:remove_const, :Municipality) }

      it "raises an exception" do
        expect do
          Municipality.find_by_name("Oregon")
        end.to raise_error(ActiveHash::FileTypeMismatchError)
      end
    end
  end
end
