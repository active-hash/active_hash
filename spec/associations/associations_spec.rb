require 'spec_helper'

describe ActiveHash::Base, "associations" do

  before do
    class City < ActiveHash::Base
      include ActiveHash::Associations
    end

    class Author < ActiveHash::Base
      include ActiveHash::Associations
    end

    class SchoolStatus < ActiveHash::Base
    end
  end

  after do
    Object.send :remove_const, :City
    Object.send :remove_const, :Author
    Object.send :remove_const, :SchoolStatus
  end

  describe "#has_many" do

    context "with ActiveHash children" do
      context "with default options" do
        before do
          Author.field :city_id
          @included_author_1 = Author.create :city_id => 1
          @included_author_2 = Author.create :city_id => 1
          @excluded_author = Author.create :city_id => 2
        end

        it "find the correct records" do
          City.has_many :authors
          city = City.create :id => 1
          expect(city.authors).to eq([@included_author_1, @included_author_2])
        end

        it "uses the correct class name when passed" do
          City.has_many :writers, :class_name => "Author"
          city = City.create :id => 1
          expect(city.writers).to eq([@included_author_1, @included_author_2])
        end
      end

      context "with a primary_key option" do
        before do
          Author.field :city_id
          City.field :author_identifier
          @author_1 = Author.create :city_id => 1
          @author_2 = Author.create :city_id => 10
          @author_3 = Author.create :city_id => 10
          City.has_many :authors, :primary_key => :author_identifier
        end

        it "finds the correct records" do
          city = City.create :id => 1, :author_identifier => 10
          expect(city.authors).to eq([@author_2, @author_3])
        end
      end

      context "with a foreign_key option" do
        before do
          Author.field :city_id
          Author.field :city_identifier
          @author_1 = Author.create :city_id => 1, :city_identifier => 10
          @author_2 = Author.create :city_id => 10, :city_identifier => 10
          @author_3 = Author.create :city_id => 10, :city_identifier => 5
          City.has_many :authors, :foreign_key => :city_identifier
        end

        it "finds the correct records" do
          city = City.create :id => 10
          expect(city.authors).to eq([@author_1, @author_2])
        end
      end
    end

  end

  describe "#belongs_to" do

    context "with an ActiveHash parent" do
      it "find the correct records" do
        Author.belongs_to :city
        city = City.create
        author = Author.create :city_id => city.id
        expect(author.city).to eq(city)
      end

      it "returns nil when the record does not exist" do
        Author.belongs_to :city
        author = Author.create :city_id => 123
        expect(author.city).to be_nil
      end
    end

    describe "#parent=" do
      before do
        Author.belongs_to :city
        @city = City.create :id => 1
      end

      it "sets the underlying id of the parent" do
        author = Author.new
        author.city = @city
        expect(author.city_id).to eq(@city.id)
      end

      it "works from hash assignment" do
        author = Author.new :city => @city
        expect(author.city_id).to eq(@city.id)
        expect(author.city).to eq(@city)
      end

      it "works with nil" do
        author = Author.new :city => @city
        expect(author.city_id).to eq(@city.id)
        expect(author.city).to eq(@city)

        author.city = nil
        expect(author.city_id).to be_nil
        expect(author.city).to be_nil
      end
    end

    describe "with a different foreign key" do
      before do
        Author.belongs_to :residence, :class_name => "City", :foreign_key => "city_id"
        @city = City.create :id => 1
      end

      it "works" do
        author = Author.new
        author.residence = @city
        expect(author.city_id).to eq(@city.id)
      end
    end

    describe "with a different primary key" do
      before do
        City.field :long_identifier
        Author.belongs_to :city, :primary_key => "long_identifier"
        @city = City.create :id => 1, :long_identifier => "123"
      end

      it "works" do
        author = Author.new
        author.city = @city
        expect(author.city_id).to eq(@city.long_identifier)
      end
    end
  end

  describe "#has_one" do
    context "with ActiveHash children" do
      before do
        City.has_one :author
        Author.field :city_id
      end

      it "find the correct records" do
        city = City.create :id => 1
        author = Author.create :city_id => 1
        expect(city.author).to eq(author)
      end

      it "returns nil when there are no records" do
        city = City.create :id => 1
        expect(city.author).to be_nil
      end
    end
  end

  describe "#marked_for_destruction?" do
    it "should return false" do
      expect(City.new.marked_for_destruction?).to eq(false)
    end
  end

end
