require 'spec_helper'
require 'active_record'

describe ActiveHash::Base, "associations" do

  before do
    class Country < ActiveRecord::Base
      establish_connection :adapter => "sqlite3", :database => ":memory:"
      connection.create_table(:countries, :force => true) do |t|
        t.string :name
      end
      extend ActiveHash::Associations::ActiveRecordExtensions
    end

    class School < ActiveRecord::Base
      establish_connection :adapter => "sqlite3", :database => ":memory:"
      connection.create_table(:schools, :force => true) do |t|
        t.integer :country_id
        t.integer :city_id
      end
      extend ActiveHash::Associations::ActiveRecordExtensions
    end

    class City < ActiveHash::Base
      include ActiveHash::Associations
    end

    class Author < ActiveHash::Base
      include ActiveHash::Associations
    end

    class SchoolStatus < ActiveHash::Base
    end

    class Book < ActiveRecord::Base
      establish_connection :adapter => "sqlite3", :database => ":memory:"
      connection.create_table(:books, :force => true) do |t|
        t.integer :author_id
        t.integer :author_code
        t.boolean :published
      end

      if Object.const_defined?(:ActiveModel)
        scope( :published, proc { where(:published => true) })
      else
        named_scope :published, {:conditions => {:published => true}}
      end
    end
  end

  after do
    Object.send :remove_const, :City
    Object.send :remove_const, :Author
    Object.send :remove_const, :Country
    Object.send :remove_const, :School
    Object.send :remove_const, :Book
  end

  describe "#has_many" do

    context "with ActiveRecord children" do
      context "with default options" do
        before do
          @book_1 = Book.create! :author_id => 1, :published => true
          @book_2 = Book.create! :author_id => 1, :published => false
          @book_3 = Book.create! :author_id => 2, :published => true
          Author.has_many :books
        end

        it "find the correct records" do
          author = Author.create :id => 1
          author.books.should == [@book_1, @book_2]
        end

        it "return a scope so that we can apply further scopes" do
          author = Author.create :id => 1
          author.books.published.should == [@book_1]
        end
      end

      context "with a primary_key option" do
        before do
          @book_1 = Book.create! :author_id => 1, :published => true
          @book_2 = Book.create! :author_id => 2, :published => false
          @book_3 = Book.create! :author_id => 2, :published => true
          Author.field :book_identifier
          Author.has_many :books, :primary_key => :book_identifier
        end

        it "should find the correct records" do
          author = Author.create :id => 1, :book_identifier => 2
          author.books.should == [@book_2, @book_3]
        end

        it "return a scope so that we can apply further scopes" do
          author = Author.create :id => 1, :book_identifier => 2
          author.books.published.should == [@book_3]
        end
      end

      context "with a foreign_key option" do
        before do
          @book_1 = Book.create! :author_code => 1, :published => true
          @book_2 = Book.create! :author_code => 1, :published => false
          @book_3 = Book.create! :author_code => 2, :published => true
          Author.has_many :books, :foreign_key => :author_code
        end

        it "should find the correct records" do
          author = Author.create :id => 1
          author.books.should == [@book_1, @book_2]
        end

        it "return a scope so that we can apply further scopes" do
          author = Author.create :id => 1
          author.books.published.should == [@book_1]
        end
      end

      it "only uses 1 query" do
        Author.has_many :books
        author = Author.create :id => 1
        Book.should_receive(:find_by_sql)
        author.books.to_a
      end
    end

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
          city.authors.should == [@included_author_1, @included_author_2]
        end

        it "uses the correct class name when passed" do
          City.has_many :writers, :class_name => "Author"
          city = City.create :id => 1
          city.writers.should == [@included_author_1, @included_author_2]
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
          city.authors.should == [@author_2, @author_3]
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
          city.authors.should == [@author_1, @author_2]
        end
      end
    end

  end

  describe ActiveHash::Associations::ActiveRecordExtensions do

    describe "#belongs_to" do

      if ActiveRecord::VERSION::MAJOR > 3
        it "doesn't interfere with AR's procs in belongs_to methods" do
          School.belongs_to :country, lambda{ where( ) }
          school = School.new
          country = Country.create!
          school.country = country
          school.country.should == country
          school.country_id.should == country.id
          school.save!
          school.reload
          school.reload.country_id.should == country.id
        end
      end

      it "sets up an ActiveRecord association for non-ActiveHash objects" do
        School.belongs_to :country
        school = School.new
        country = Country.create!
        school.country = country
        school.country.should == country
        school.country_id.should == country.id
        school.save!
        school.reload
        school.reload.country_id.should == country.id
      end

      it "calls through to belongs_to_active_hash if it's an ActiveHash object" do
        School.belongs_to :city
        city = City.create
        school = School.create :city_id => city.id
        school.city.should == city
      end
    end

    describe "#belongs_to_active_hash" do
      context "setting by id" do
        it "finds the correct records" do
          School.belongs_to_active_hash :city
          city = City.create
          school = School.create :city_id => city.id
          school.city.should == city
        end

        it "returns nil when the record does not exist" do
          School.belongs_to_active_hash :city
          school = School.create! :city_id => nil
          school.city.should be_nil
        end
      end

      context "setting by association" do
        it "finds the correct records" do
          School.belongs_to_active_hash :city
          city = City.create
          school = School.create :city => city
          school.city.should == city
        end

        it "is assignable by name attribute" do
          School.belongs_to_active_hash :city, :shortcuts => [:name]
          City.data = [ {:id => 1, :name => 'gothan'} ]
          city = City.find_by_name 'gothan'
          school = School.create :city_name => 'gothan'
          school.city.should == city
          school.city_name.should == 'gothan'
        end

        it "have custom shortcut" do
          School.belongs_to_active_hash :city, :shortcuts => :friendly_name
          City.data = [ {:id => 1, :friendly_name => 'Gothan City'} ]
          city = City.find_by_friendly_name 'Gothan City'
          school = School.create :city_friendly_name => 'Gothan City'
          school.city.should == city
          school.city_friendly_name.should == 'Gothan City'
        end

        it "returns nil when the record does not exist" do
          School.belongs_to_active_hash :city
          school = School.create! :city => nil
          school.city.should be_nil
        end
      end

      it "finds active record metadata for this association" do
        School.belongs_to_active_hash :city
        association = School.reflect_on_association(:city)
        association.should_not be_nil
        association.klass.name.should == City.name
      end

      it "handles classes ending with an 's'" do
        School.belongs_to_active_hash :school_status
        association = School.reflect_on_association(:school_status)
        association.should_not be_nil
        association.klass.name.should == SchoolStatus.name
      end

      it "handles custom association names" do
        School.belongs_to_active_hash :status, :class_name => 'SchoolStatus'
        association = School.reflect_on_association(:status)
        association.should_not be_nil
        association.klass.name.should == SchoolStatus.name
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

    describe "with a different primary key" do
      before do
        City.field :long_identifier
        Author.belongs_to :city, :primary_key => "long_identifier"
        @city = City.create :id => 1, :long_identifier => "123"
      end

      it "works" do
        author = Author.new
        author.city = @city
        author.city_id.should == @city.long_identifier
      end
    end
  end

  describe "#has_one" do
    context "with ActiveRecord children" do
      before do
        Author.has_one :book
      end

      it "find the correct records" do
        book = Book.create! :author_id => 1, :published => true
        author = Author.create :id => 1
        author.book.should == book
      end

      it "returns nil when there is no record" do
        author = Author.create :id => 1
        author.book.should be_nil
      end
    end

    context "with ActiveHash children" do
      before do
        City.has_one :author
        Author.field :city_id
      end

      it "find the correct records" do
        city = City.create :id => 1
        author = Author.create :city_id => 1
        city.author.should == author
      end

      it "returns nil when there are no records" do
        city = City.create :id => 1
        city.author.should be_nil
      end
    end
  end

  describe "#marked_for_destruction?" do
    it "should return false" do
      City.new.marked_for_destruction?.should == false
    end
  end

end
