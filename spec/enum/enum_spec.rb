require 'spec/spec_helper'

describe ActiveHash::Base, "enum" do

  before do
    ActiveYaml::Base.set_root_path File.expand_path(File.dirname(__FILE__) + "/../fixtures")
    
    class Borough < ActiveYaml::Base
      include ActiveHash::Enum
      fields :name, :county, :population
    end
  end

  after do
    Object.send(:remove_const, :Borough)
  end

  describe "#enum_accessor" do
    it "sets the field used for accessing records by constants" do
      Borough.enum_accessor :name
      Borough::BROOKLYN.should == Borough.find_by_name("Brooklyn")
    end
    
    it "ensures that values stored in the field specified are unique" do
      lambda do
        Class.new(ActiveHash::Base) do
          include ActiveHash::Enum
          self.data = [
            { :name => 'Woodford Reserve' },
            { :name => 'Bulliet Bourbon' },
            { :name => 'Woodford Reserve' }
          ]
          enum_accessor :name 
        end
      end.should raise_error(ActiveHash::Enum::DuplicateConstant)
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
      
      Movie::DIEHARD.name.should == 'Die Hard 2'
      Movie::THEINFORMANT.name.should == 'The Informant!'
      Movie::INOUT.name.should == 'In & Out'
    end
  end

end
