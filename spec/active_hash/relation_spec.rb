require 'spec_helper'

RSpec.describe ActiveHash::Relation do
  let(:model_class) do
    Class.new(ActiveHash::Base) do
      self.data = [
        {:id => 1, :name => "US"},
        {:id => 2, :name => "Canada"}
      ]
    end
  end

  subject { model_class.all }

  describe '#sample' do
    it 'delegate `sample` to Array' do
      expect(subject).to respond_to(:sample)
    end

    it 'return a random element or n random elements' do
      records = subject

      expect(records.sample).to be_present
      expect(records.sample(2).count).to eq(2)
    end
  end

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

  describe '#size' do
    it 'returns an Integer' do
      expect(subject.size).to be_an(Integer)
    end

    it 'returns the correct number of items of the relation' do
      array = subject.to_ary

      expect(array.size).to eq(2)
    end
  end
end
