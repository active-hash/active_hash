require 'spec_helper'

RSpec.describe ActiveHash::Relation do
  class Country < ActiveHash::Base
    self.data = [
      {:id => 1, :name => "US"},
      {:id => 2, :name => "Canada"}
    ]
  end
  
  subject { Country.all }
  
  describe '#to_ary' do
    it 'returns an array' do
      expect(subject.to_ary).to be_an(Array)
    end
    
    it 'contains the same items as the relation' do
      array = subject.to_ary
      
      expect(array.length).to eq(subject.count)
      expect(array.first.id).to eq(1)
      expect(array.second.id).to eq(2)
    end
  end
end