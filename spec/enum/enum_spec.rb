require 'spec_helper'

describe ActiveHash::Base, "enum" do

  before do
    ActiveYaml::Base.set_root_path File.expand_path(File.dirname(__FILE__) + "/../fixtures")

    class Borough < ActiveYaml::Base
      include ActiveHash::Enum
      fields :name, :county, :population
      enum_accessor :name
    end

    class Neighborhood < ActiveHash::Base
      include ActiveHash::Enum
      fields :name, :county
      enum_accessor :name, :county

      self.data = [
        {:name => "Queen Ann", :county => "King"}
      ]
    end
  end

  after do
    Object.send(:remove_const, :Borough)
    Object.send(:remove_const, :Neighborhood)
  end

  describe "#enum_accessor" do
    it "can use a custom method" do
      Borough::BROOKLYN.should == Borough.find_by_name("Brooklyn")
    end

    it "sets the field used for accessing records by constants" do
      Neighborhood::QUEEN_ANN_KING.should == Neighborhood.find_by_name("Queen Ann")
    end

    it "ensures that values stored in the field specified are unique" do
      lambda do
        Class.new(ActiveHash::Base) do
          include ActiveHash::Enum
          self.data = [
            {:name => 'Woodford Reserve'},
            {:name => 'Bulliet Bourbon'},
            {:name => 'Woodford Reserve'}
          ]
          enum_accessor :name
        end
      end.should raise_error(ActiveHash::Enum::DuplicateEnumAccessor)
    end

    it "removes non-word characters from values before setting constants" do
      Movie = Class.new(ActiveHash::Base) do
        include ActiveHash::Enum
        self.data = [
          {:name => 'Die Hard 2', :rating => '4.3'},
          {:name => 'The Informant!', :rating => '4.3'},
          {:name => 'In & Out', :rating => '4.3'}
        ]
        enum_accessor :name
      end

      Movie::DIE_HARD_2.name.should == 'Die Hard 2'
      Movie::THE_INFORMANT.name.should == 'The Informant!'
      Movie::IN_OUT.name.should == 'In & Out'
    end
  end

  context "ActiveHash with an enum_accessor set" do
    describe "#save" do
      it "resets the constant's value to the updated record" do
        Borough::BROOKLYN.population.should == 2556598
        brooklyn = Borough.find_by_name("Brooklyn")
        brooklyn.population = 2556600
        brooklyn.save.should be_true
        Borough::BROOKLYN.population.should == 2556600
      end
    end

    describe ".create" do
      it "creates constants for new records" do
        bronx = Borough.create!(:name => "Bronx")
        Borough::BRONX.should == bronx
      end

      it "doesn't create constants for records missing the enum accessor field" do
        Borough.create(:name => "").should be_true
        Borough.create(:population => 12).should be_true
      end
    end

    describe ".delete_all" do
      it "unsets all constants for deleted records" do
        Borough.const_defined?("STATEN_ISLAND").should be_true
        Borough.delete_all.should be_true
        Borough.const_defined?("STATEN_ISLAND").should be_false
      end
    end
  end
end
