require 'spec_helper'

describe ActiveFile::MultipleFiles do
  before do
    class Country < ActiveFile::Base
      use_multiple_files
    end
  end

  after do
    Object.send :remove_const, :Country
  end

  describe ".filenames=" do
    before do
      Country.filenames = ["country-file"]

      class Bar < ActiveFile::Base
        use_multiple_files
        self.filenames = ["bar-file"]
      end
    end
    after { Object.send :remove_const, :Bar }

    it "sets the filenames on a per-subclass basis" do
      expect(Country.filenames).to eq(["country-file"])
      expect(Bar.filenames).to eq(["bar-file"])
    end
  end

  describe "set_filenames" do
    before do
      Country.set_filenames "country-file"

      class Bar < ActiveFile::Base
        use_multiple_files
        set_filenames "bar-file", "baz-file"
      end
    end
    after { Object.send :remove_const, :Bar }

    it "sets the filenames on a per-subclass basis" do
      expect(Country.filenames).to eq(["country-file"])
      expect(Bar.filenames).to eq(["bar-file", "baz-file"])
    end
  end

  describe ".multiple_files?" do
    it "is true" do
      expect(Country.multiple_files?).to be_truthy
    end

    context "on a per class basis" do
      before do
        class Bar < ActiveFile::Base
        end
      end
      after { Object.send :remove_const, :Bar }

      it "is true for classes with filenames" do
        expect(Country.multiple_files?).to be_truthy
        expect(Bar.multiple_files?).to be_falsey
      end
    end
  end

  describe ".full_paths" do
    it "defaults to the directory of the calling file" do
      class Country
        def self.extension() "foo" end
      end

      expect(Country.full_paths).to eq(["#{Dir.pwd}/countries.foo"])
    end

    context "given multiple files do" do
      it "is good" do
        class Country
          def self.extension() "foo" end
          self.filenames = ["fizz", "bazz"]
        end

        expect(Country.full_paths).to eq(["#{Dir.pwd}/fizz.foo", "#{Dir.pwd}/bazz.foo"])
      end
    end
  end
end
