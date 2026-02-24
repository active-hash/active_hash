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

  describe '#count' do
    it 'supports a block arg' do
      expect(subject.count { |s| s.name == "US" }).to eq(1)
    end

    it 'returns the correct number of items of the relation' do
      expect(subject.count).to eq(2)
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

  describe '#or' do
    it 'returns the union of two where relations' do
      r1 = model_class.where(name: "US")
      r2 = model_class.where(name: "Canada")

      result = r1.or(r2)

      expect(result.pluck(:id)).to match_array([1, 2])
    end

    it 'deduplicates records by id' do
      r1 = model_class.where(name: "US")
      r2 = model_class.where(name: "US")

      result = r1.or(r2)

      expect(result.pluck(:id)).to eq([1])
    end

    it 'returns a relation that can be chained' do
      r1 = model_class.where(name: "US")
      r2 = model_class.where(name: "Canada")

      result = r1.or(r2).where(id: 2)

      expect(result.pluck(:id)).to eq([2])
    end

    it 'raises when OR-ing relations from different models' do
      other_model = Class.new(ActiveHash::Base) do
        self.data = [{ id: 1, name: "X" }]
      end

      expect {
        model_class.where(name: "US").or(other_model.where(name: "X"))
      }.to raise_error(ArgumentError)
    end

    it 'works with order applied after or' do
      r1 = model_class.where(id: 1)
      r2 = model_class.where(id: [2])

      result = r1.or(r2).order(id: :desc)

      expect(result.pluck(:id)).to eq([2, 1])
    end
  end
end
