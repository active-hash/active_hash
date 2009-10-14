require 'spec/spec_helper'

describe ActiveYaml::Base do

  before do
    ActiveYaml::Base.set_root_path File.expand_path(File.dirname(__FILE__) + "/../fixtures")

    class Country < ActiveYaml::Base
    end

    class City < ActiveYaml::Base
    end

    class State < ActiveYaml::Base
    end
  end

  after do
    Object.send :remove_const, :Country
    Object.send :remove_const, :City
    Object.send :remove_const, :State
  end

  describe ".raw_data" do

    it "returns the raw hash data loaded from yaml hash-formatted files" do
      City.raw_data.should be_kind_of(Hash)
      City.raw_data.keys.should include("albany", "portland")
    end

    it "returns the raw array data loaded from yaml array-formatted files" do
      Country.raw_data.should be_kind_of(Array)
    end

  end

end
