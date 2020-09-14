require 'spec_helper'

unless SKIP_ACTIVE_RECORD
  describe ActiveHash::Base, "active record extensions" do

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
          t.string :locateable_type
          t.integer :locateable_id
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
          scope(:published, proc { where(:published => true) })
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
      Object.send :remove_const, :SchoolStatus
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
            expect(author.books).to eq([@book_1, @book_2])
          end

          it "return a scope so that we can apply further scopes" do
            author = Author.create :id => 1
            expect(author.books.published).to eq([@book_1])
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
            expect(author.books).to eq([@book_2, @book_3])
          end

          it "return a scope so that we can apply further scopes" do
            author = Author.create :id => 1, :book_identifier => 2
            expect(author.books.published).to eq([@book_3])
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
            expect(author.books).to eq([@book_1, @book_2])
          end

          it "return a scope so that we can apply further scopes" do
            author = Author.create :id => 1
            expect(author.books.published).to eq([@book_1])
          end
        end

        it "only uses 1 query" do
          Author.has_many :books
          author = Author.create :id => 1
          expect(Book).to receive(:find_by_sql)
          author.books.to_a
        end
      end

    end

    describe ActiveHash::Associations::ActiveRecordExtensions do

      describe "#belongs_to" do

        if ActiveRecord::VERSION::MAJOR > 3
          it "doesn't interfere with AR's procs in belongs_to methods" do
            School.belongs_to :country, lambda { where() }
            school = School.new
            country = Country.create!
            school.country = country
            expect(school.country).to eq(country)
            expect(school.country_id).to eq(country.id)
            school.save!
            school.reload
            expect(school.reload.country_id).to eq(country.id)
          end
        end

        it "doesn't interfere w/ ActiveRecord's polymorphism" do
          School.belongs_to :locateable, :polymorphic => true
          school = School.new
          country = Country.create!
          school.locateable = country
          expect(school.locateable).to eq(country)
          school.save!
          expect(school.reload.locateable_id).to eq(country.id)
        end

        it "sets up an ActiveRecord association for non-ActiveHash objects" do
          School.belongs_to :country
          school = School.new
          country = Country.create!
          school.country = country
          expect(school.country).to eq(country)
          expect(school.country_id).to eq(country.id)
          school.save!
          school.reload
          expect(school.reload.country_id).to eq(country.id)
        end

        it "calls through to belongs_to_active_hash if it's an ActiveHash object" do
          School.belongs_to :city
          city = City.create
          school = School.create :city_id => city.id
          expect(school.city).to eq(city)
        end

        it "returns nil when the belongs_to association class can't be autoloaded" do
          # Simulate autoloader
          allow_any_instance_of(String).to receive(:constantize).and_raise(LoadError, "Unable to autoload constant NonExistent")
          School.belongs_to :city, {class_name: 'NonExistent'}
        end
      end

      describe "#belongs_to_active_hash" do
        context "setting by id" do
          it "finds the correct records" do
            School.belongs_to_active_hash :city
            city = City.create
            school = School.create :city_id => city.id
            expect(school.city).to eq(city)
          end

          it "returns nil when the record does not exist" do
            School.belongs_to_active_hash :city
            school = School.create! :city_id => nil
            expect(school.city).to be_nil
          end
        end

        context "setting by association" do
          it "finds the correct records" do
            School.belongs_to_active_hash :city
            city = City.create
            school = School.create :city => city
            expect(school.city).to eq(city)
          end

          it "is assignable by name attribute" do
            School.belongs_to_active_hash :city, :shortcuts => [:name]
            City.data = [{:id => 1, :name => 'gothan'}]
            city = City.find_by_name 'gothan'
            school = School.create :city_name => 'gothan'
            expect(school.city).to eq(city)
            expect(school.city_name).to eq('gothan')
          end

          it "have custom shortcut" do
            School.belongs_to_active_hash :city, :shortcuts => :friendly_name
            City.data = [{:id => 1, :friendly_name => 'Gothan City'}]
            city = City.find_by_friendly_name 'Gothan City'
            school = School.create :city_friendly_name => 'Gothan City'
            expect(school.city).to eq(city)
            expect(school.city_friendly_name).to eq('Gothan City')
          end

          it "returns nil when the record does not exist" do
            School.belongs_to_active_hash :city
            school = School.create! :city => nil
            expect(school.city).to be_nil
          end
        end

        it "finds active record metadata for this association" do
          School.belongs_to_active_hash :city
          association = School.reflect_on_association(:city)
          expect(association).not_to be_nil
          expect(association.klass.name).to eq(City.name)
        end

        it "handles classes ending with an 's'" do
          School.belongs_to_active_hash :school_status
          association = School.reflect_on_association(:school_status)
          expect(association).not_to be_nil
          expect(association.klass.name).to eq(SchoolStatus.name)
        end

        it "handles custom association names" do
          School.belongs_to_active_hash :status, :class_name => 'SchoolStatus'
          association = School.reflect_on_association(:status)
          expect(association).not_to be_nil
          expect(association.klass.name).to eq(SchoolStatus.name)
        end
      end
    end

    describe "#belongs_to" do

      context "with an ActiveRecord parent" do
        it "find the correct records" do
          City.belongs_to :country
          country = Country.create
          city = City.create :country_id => country.id
          expect(city.country).to eq(country)
        end

        it "returns nil when the record does not exist" do
          City.belongs_to :country
          city = City.create :country_id => 123
          expect(city.country).to be_nil
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
          expect(author.book).to eq(book)
        end

        it "returns nil when there is no record" do
          author = Author.create :id => 1
          expect(author.book).to be_nil
        end
      end
    end

  end
end
