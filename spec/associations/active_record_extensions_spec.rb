require 'spec_helper'

unless SKIP_ACTIVE_RECORD
  describe ActiveHash::Base, "active record extensions" do

    def define_ephemeral_class(name, superclass, &block)
      klass = Class.new(superclass)
      Object.const_set(name, klass)
      klass.class_eval(&block) if block_given?
      @ephemeral_classes << name
    end

    def define_book_classes
      define_ephemeral_class(:Author, ActiveHash::Base) do
        include ActiveHash::Associations
      end

      define_ephemeral_class(:Book, ActiveRecord::Base) do
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

    def define_person_classes
      define_ephemeral_class(:Country, ActiveHash::Base) do
        self.data = [
          {:id => 1, :name => "Japan"}
        ]
      end

      define_ephemeral_class(:Person, ActiveRecord::Base) do
        establish_connection :adapter => "sqlite3", :database => ":memory:"
        connection.create_table(:people, :force => true) do |t|
        end

        extend ActiveHash::Associations::ActiveRecordExtensions
      end

      define_ephemeral_class(:Post, ActiveRecord::Base) do
        establish_connection :adapter => "sqlite3", :database => ":memory:"
        connection.create_table(:posts, :force => true) do |t|
          t.integer :person_id
          t.datetime :created_at
        end

        belongs_to :person
      end
    end

    def define_school_classes
      define_ephemeral_class(:Country, ActiveRecord::Base) do
        establish_connection :adapter => "sqlite3", :database => ":memory:"
        connection.create_table(:countries, :force => true) do |t|
          t.string :name
        end
        extend ActiveHash::Associations::ActiveRecordExtensions
      end

      define_ephemeral_class(:School, ActiveRecord::Base) do
        establish_connection :adapter => "sqlite3", :database => ":memory:"
        connection.create_table(:schools, :force => true) do |t|
          t.integer :country_id
          t.string :locateable_type
          t.integer :locateable_id
          t.integer :city_id
        end

        extend ActiveHash::Associations::ActiveRecordExtensions
      end

      define_ephemeral_class(:City, ActiveHash::Base) do
        include ActiveHash::Associations
      end

      define_ephemeral_class(:SchoolStatus, ActiveHash::Base)
    end

    def define_doctor_classes
      define_ephemeral_class(:Physician, ActiveHash::Base) do
        include ActiveHash::Associations

        has_many :appointments
        has_many :patients, through: :appointments

        self.data = [
          {:id => 1, :name => "ikeda"},
          {:id => 2, :name => "sato"}
        ]
      end

      define_ephemeral_class(:Appointment, ActiveRecord::Base) do
        establish_connection :adapter => "sqlite3", :database => ":memory:"
        connection.create_table :appointments, force: true do |t|
          t.references :physician
          t.references :patient
        end

        extend ActiveHash::Associations::ActiveRecordExtensions

        belongs_to :physician
        belongs_to :patient
      end

      define_ephemeral_class(:Patient, ActiveRecord::Base) do
        establish_connection :adapter => "sqlite3", :database => ":memory:"
        connection.create_table :patients, force: true do |t|
        end

        extend ActiveHash::Associations::ActiveRecordExtensions

        has_many :appointments
        has_many :physicians, through: :appointments
      end

    end

    before do
      @ephemeral_classes = []
    end

    after do
      @ephemeral_classes.each do |klass_name|
        Object.send :remove_const, klass_name
      end
    end

    describe "#has_many" do
      context "with ActiveRecord children" do
        before { define_book_classes }

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

          it "should find the correct record ids" do
            author = Author.create :id => 1
            expect(author.book_ids).to eq([@book_1.id, @book_2.id])
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

          it "should find the correct record ids" do
            author = Author.create :id => 1, :book_identifier => 2
            expect(author.book_ids).to eq([@book_2.id, @book_3.id])
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

          it "should find the correct record ids" do
            author = Author.create :id => 1
            expect(author.book_ids).to eq([@book_1.id, @book_2.id])
          end

          it "return a scope so that we can apply further scopes" do
            author = Author.create :id => 1
            expect(author.books.published).to eq([@book_1])
          end
        end

        it "only uses 1 query" do
          Author.has_many :books
          author = Author.create :id => 1
          expect(Book).to receive(:where).with(author_id: 1).once.and_call_original
          author.books.to_a
        end
      end

      describe ":through" do
        before { define_doctor_classes }

        it "finds ActiveHash records through the join model" do
          patient = Patient.create!

          physician1 = Physician.first
          Appointment.create!(physician: physician1, patient: patient)
          Appointment.create!(physician: physician1, patient: patient)

          physician2 = Physician.last
          Appointment.create!(physician: physician2, patient: patient)

          expect(patient.physicians).to contain_exactly(physician1, physician2)
        end

        describe "with the :source option" do
          before do
            # NOTE: Removing the Patient#physicians association and adding Patient#doctors
            Patient._reflections.delete('physicians')
            Patient.class_eval do
              define_method(:physicians) { raise NoMethodError, "The #physicians association is removed in this spec, use #doctors" }
              define_method(:physicians=) { |_| raise NoMethodError, "The #physicians association is removed in this spec, use #doctors" }
            end
            Patient.has_many :doctors, through: :appointments, source: :physician
          end

          it "finds ActiveHash records through the join model" do
            patient = Patient.create!

            physician = Physician.last
            Appointment.create!(physician: physician, patient: patient)

            expect(patient.doctors).to contain_exactly(physician)
          end
        end

        describe ":through when the join model uses an aliased association" do
          before do
            # NOTE: Removing the Appointment#physician association and adding Appointment#doctor
            Appointment._reflections.delete('physician')
            Appointment.class_eval do
              define_method(:physician) { raise NoMethodError, "The #physician association is removed in this spec, use #doctor" }
              define_method(:physician=) { |_| raise NoMethodError, "The #physician association is removed in this spec, use #doctor" }
            end
            Appointment.belongs_to :doctor, class_name: 'Physician', foreign_key: :physician_id

            # NOTE: Removing the Patient#physicians association and adding Patient#doctors
            Patient._reflections.delete('physicians')
            Patient.class_eval do
              define_method(:physicians) { raise NoMethodError, "The #physicians association is removed in this spec, use #doctors" }
              define_method(:physicians=) { |_| raise NoMethodError, "The #physicians association is removed in this spec, use #doctors" }
            end
            Patient.has_many :doctors, through: :appointments
          end

          it "finds ActiveHash records through the join model" do
            patient = Patient.create!

            physician = Physician.last
            Appointment.create!(doctor: physician, patient: patient)

            expect(patient.doctors).to contain_exactly(physician)
          end
        end
      end

      describe "with a lambda" do
        before do
          define_person_classes
          now = Time.now
          @post_1 = Post.create! :person_id => 1, :created_at => now
          @post_2 = Post.create! :person_id => 1, :created_at => 1.day.ago
          Post.create! :person_id => 2, :created_at => now
          Person.has_many :posts, lambda { order(created_at: :asc) }
        end

        it "should find the correct records" do
          person = Person.create :id => 1
          expect(person.posts).to eq([@post_2, @post_1])
        end
      end
    end

    describe ActiveHash::Associations::ActiveRecordExtensions do
      describe "#belongs_to" do
        before { define_school_classes }

        it "doesn't interfere with AR's procs in belongs_to methods" do
          School.belongs_to :country, lambda { where(name: 'Japan') }
          school = School.new
          country = Country.create!(id: 1, name: 'Japan')
          school.country = country
          expect(school.country).to eq(country)
          expect(school.country_id).to eq(country.id)
          expect(school.country).to eq(country)
          school.save!
          school.reload
          expect(school.country_id).to eq(country.id)
          expect(school.country).to eq(country)

          country.update!(name: 'JAPAN')
          school.reload
          expect(school.country_id).to eq(country.id)
          expect(school.country).to eq(nil)
        end

        it "doesn't interfere with AR's belongs_to arguments" do
          allow(ActiveRecord::Base).to receive(:belongs_to).with(:country, nil)
          allow(ActiveRecord::Base).to receive(:belongs_to).with(:country, nil, {})

          School.belongs_to :country
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

        it "doesn't raise any exception when the belongs_to association class can't be autoloaded" do
          # Simulate autoloader
          allow_any_instance_of(String).to receive(:constantize).and_raise(LoadError, "Unable to autoload constant NonExistent")
          expect { School.belongs_to :city, class_name: 'NonExistent' }.not_to raise_error
        end
      end

      describe "#belongs_to_active_hash" do
        before { define_school_classes }

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
        before { define_school_classes }

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
          define_book_classes
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
