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

  describe "colliding methods https://github.com/active-hash/active_hash/issues/280" do
    it "should handle attributes named after existing methods" do
      klass = Class.new(ActiveHash::Base) do
        self.data = [
          {
            id: 1,
            name: "Aaa",
            display: true,
          },
          {
            id: 2,
            name: "Bbb",
            display: false,
          },
        ]
      end

      expect(klass.where(display: true).length).to eq(1)
    end
  end

  describe "#pretty_print" do
    it "prints the records" do
      out = StringIO.new
      PP.pp(subject, out)

      expect(out.string.scan(/\bid\b/).length).to eq(2)
      expect(out.string).to match(/\bCanada\b/)
      expect(out.string).to match(/\bUS\b/)
      expect(out.string).to_not match(/ActiveHash::Relation/)
    end
  end
end
