require 'spec_helper'

describe ActiveFile::Base do
  before do
    class Country < ActiveFile::Base
    end
  end

  after do
    Object.send :remove_const, :Country
  end

  describe ".multiple_files?" do
    it "is false" do
      expect(Country.multiple_files?).to be_falsey
    end
  end

  describe ".filename=" do
    before do
      Country.filename = "foo-izzle"

      class Bar < ActiveFile::Base
        self.filename = "bar-izzle"
      end
    end
    after { Object.send :remove_const, :Bar }

    it "sets the filename on a per-subclass basis" do
      expect(Country.filename).to eq("foo-izzle")
      expect(Bar.filename).to eq("bar-izzle")
    end
  end

  describe ".set_filename" do
    before do
      Country.set_filename "foo-izzle"

      class Bar < ActiveFile::Base
        set_filename "bar-izzle"
      end
    end
    after { Object.send :remove_const, :Bar }

    it "sets the filename on a per-subclass basis" do
      expect(Country.filename).to eq("foo-izzle")
      expect(Bar.filename).to eq("bar-izzle")
    end
  end

  describe ".root_path=" do
    before do
      Country.root_path = "foo-izzle"

      class Bar < ActiveFile::Base
        self.root_path = "bar-izzle"
      end
    end
    after { Object.send :remove_const, :Bar }

    it "sets the root_path on a per-subclass basis" do
      expect(Country.root_path).to eq("foo-izzle")
      expect(Bar.root_path).to eq("bar-izzle")
    end
  end

  describe ".set_root_path" do
    before do
      Country.set_root_path "foo-izzle"

      class Bar < ActiveFile::Base
        set_root_path "bar-izzle"
      end
    end
    after { Object.send :remove_const, :Bar }

    it "sets the root_path on a per-subclass basis" do
      expect(Country.root_path).to eq("foo-izzle")
      expect(Bar.root_path).to eq("bar-izzle")
    end
  end

  describe ".full_path" do
    it "defaults to the directory of the calling file" do
      class Country
        def self.extension() "foo" end
      end

      expect(Country.full_path).to eq("#{Dir.pwd}/countries.foo")
    end
  end

  describe ".reload" do
    before do
      class Country
        def self.load_file()
          {"new_york"=>{"name"=>"New York", "id"=>1}}.values
        end
      end
      Country.reload # initial load
    end

    context "when nothing has been modified" do
      it "does not reload anything" do
        class Country
          def self.load_file()
            raise "should not have been called"
          end
        end
        expect(Country.dirty).to be_falsey
        Country.reload
        expect(Country.dirty).to be_falsey
      end
    end

    context "when forced" do
      it "reloads the data" do
        class Country
          def self.load_file()
            {"new_york"=>{"name"=>"New York", "id"=>2}}.values
          end
        end
        expect(Country.dirty).to be_falsey
        expect(Country.find_by_id(2)).to be_nil
        Country.reload(true)
        expect(Country.dirty).to be_falsey
        expect(Country.find(2).name).to eq("New York")
      end
    end

    context "when the data has been modified" do
      it "reloads the data" do
        Country.create!
        expect(Country.dirty).to be_truthy
        Country.reload
        expect(Country.dirty).to be_falsey
      end
    end
  end

end
