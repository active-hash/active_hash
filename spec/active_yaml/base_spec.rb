require 'spec_helper'

describe ActiveYaml::Base do

  before do
    ActiveYaml::Base.set_root_path File.expand_path(File.dirname(__FILE__) + "/../fixtures")

    class ArrayRow     < ActiveYaml::Base ; end
    class City         < ActiveYaml::Base ; end
    class State        < ActiveYaml::Base ; end
    class ArrayProduct < ActiveYaml::Base ; end # Contain YAML aliases
    class KeyProduct   < ActiveYaml::Base ; end # Contain YAML aliases
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

    it "returns the raw hash data loaded from yaml hash-formatted files" do
      City.raw_data.should be_kind_of(Hash)
      City.raw_data.keys.should include("albany", "portland")
    end

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
        City.load_file.should include({"state" => :new_york, "name" => "Albany", "id" => 1})
        City.reload
        City.all.should include(City.new(:id => 1))
      end
    end

  end

  describe 'ID finders without reliance on a call to all, even with fields specified' do

    before do
      class City < ActiveYaml::Base
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

  describe 'meta programmed finders and properties for fields that exist in the YAML' do

    it 'should have a finder method for each property' do
      City.find_by_state('Oregon').should_not be_nil
    end

    it 'should have a find all method for each property' do
      City.find_all_by_state('Oregon').should_not be_nil
    end

  end

end
