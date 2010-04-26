require 'spec/spec_helper'

describe ActiveHash::Base, "associations" do

  before do
    build_model :countries do
    end

    class City < ActiveHash::Base
      include ActiveHash::Associations
    end

    class Author < ActiveHash::Base
      include ActiveHash::Associations
    end

    build_model :books do
      integer :author_id
    end
  end

  after do
    Object.send :remove_const, :City
    Object.send :remove_const, :Author
  end

  describe "#has_many" do

    context "with ActiveRecord children" do
      before do
        @included_book_1  = Book.create! :author_id => 1
        @included_book_2  = Book.create! :author_id => 1
        @excluded_book    = Book.create! :author_id => 2
      end

      it "find the correct records" do
        Author.has_many :books
        author = Author.create :id => 1
        author.books.should =~ [@included_book_1, @included_book_2]
      end
    end

    context "with ActiveHash children" do
      before do
        Author.field :city_id
        @included_author_1  = Author.create :city_id => 1
        @included_author_2  = Author.create :city_id => 1
        @excluded_author    = Author.create :city_id => 2
      end

      it "find the correct records" do
        City.has_many :authors
        city = City.create :id => 1
        city.authors.should =~ [@included_author_1, @included_author_2]
      end

      it "uses the correct class name when passed" do
        City.has_many :writers, :class_name => "Author"
        city = City.create :id => 1
        city.writers.should =~ [@included_author_1, @included_author_2]
      end
    end

  end

  describe "#belongs_to" do

    context "with an ActiveRecord parent" do
      it "find the correct records" do
        City.belongs_to :country
        country = Country.create
        city = City.create :country_id => country.id
        city.country.should == country
      end

      it "returns nil when the record does not exist" do
        City.belongs_to :country
        city = City.create :country_id => 123
        city.country.should be_nil
      end
    end

    context "with an ActiveHash parent" do
      it "find the correct records" do
        Author.belongs_to :city
        city = City.create
        author = Author.create :city_id => city.id
        author.city.should == city
      end

      it "returns nil when the record does not exist" do
        Author.belongs_to :city
        author = Author.create :city_id => 123
        author.city.should be_nil
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
        author.city_id.should == @city.id
      end

      it "works from hash assignment" do
        author = Author.new :city => @city
        author.city_id.should == @city.id
        author.city.should == @city
      end

      it "works with nil" do
        author = Author.new :city => @city
        author.city_id.should == @city.id
        author.city.should == @city

        author.city = nil
        author.city_id.should be_nil
        author.city.should be_nil
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
        author.city_id.should == @city.id
      end
    end

  end

  describe "#marked_for_destruction?" do
    it "should return false" do
      City.new.marked_for_destruction?.should == false
    end
  end

end
