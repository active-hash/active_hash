require 'spec/spec_helper'

describe ActiveYaml::Base do

  before do
    ActiveYaml::Base.set_root_path File.expand_path(File.dirname(__FILE__) + "/../fixtures")

    class ArrayRow < ActiveYaml::Base
    end

    class City < ActiveYaml::Base
    end

    class State < ActiveYaml::Base
    end
  end

  after do
    Object.send :remove_const, :ArrayRow
    Object.send :remove_const, :City
    Object.send :remove_const, :State
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
        City.all.should include( City.new(:id => 1) )
      end
    end

  end

end
