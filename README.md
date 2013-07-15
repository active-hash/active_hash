# ActiveHash

[![Build Status](https://travis-ci.org/zilkey/active_hash.png?branch=master)](https://travis-ci.org/zilkey/active_hash)

ActiveHash is a simple base class that allows you to use a ruby hash as a readonly datasource for an ActiveRecord-like model.

ActiveHash assumes that every hash has an :id key, which is what you would probably store in a database.  This allows you to seemlessly upgrade from ActiveHash objects to full ActiveRecord objects without having to change any code in your app, or any foreign keys in your database.

It also allows you to use #has_many and #belongs_to (via belongs_to_active_hash) in your AR objects.

ActiveHash can also be useful to create simple test classes that run without a database - ideal for testing plugins or gems that rely on simple AR behavior, but don't want to deal with databases or migrations for the spec suite.

ActiveHash also ships with:

  * ActiveFile: a base class that you can use to create file data sources
  * ActiveYaml: a base class that will turn YAML into a hash and load the data into an ActiveHash object

## Installation

Make sure gemcutter.org is one of your gem sources, then run:

    sudo gem install active_hash

## Usage

To use ActiveHash, you need to:

 * Inherit from ActiveHash::Base
 * Define your data
 * Define your fields and/or default values

A quick example would be:

    class Country < ActiveHash::Base
      self.data = [
        {:id => 1, :name => "US"},
        {:id => 2, :name => "Canada"}
      ]
    end

    country = Country.new(:name => "Mexico")
    country.name  # => "Mexico"
    country.name? # => true

You can also use _create_:

    class Country < ActiveHash::Base
      field :name
      create :id => 1, :name => "US"
      create :id => 2, :name => "Canada"
    end

If you are Pat Nakajima,  you probably prefer _add_:

    class Country < ActiveHash::Base
      field :name
      add :id => 1, :name => "US"
      add :id => 2, :name => "Canada"
    end

## WARNING

If you add data to an ActiveHash file during an initializer, it will not be reloaded in development in Rails.

## Auto-Defined fields

ActiveHash will auto-define all fields for you when you load the hash.  For example, if you have the following class:

    class CustomField < ActiveHash::Base
      self.data = [
        {:custom_field_1 => "foo"},
        {:custom_field_2 => "foo"},
        {:custom_field_3 => "foo"}
      ]
    end

Once you call CustomField.all it will define methods for :custom_field_1, :custom_field_2 etc...

If you need the fields at load time, as opposed to after .all is called, you can also define them manually, like so:

    class CustomField < ActiveHash::Base
      fields :custom_field_1, :custom_field_2, :custom_field_3
    end

NOTE: auto-defined fields will _not_ override fields you've defined, either on the class or on the instance.

## Defining Fields with default values

If some of your hash values contain nil, and you want to provide a default, you can specify defaults with the :field method:

    class Country < ActiveHash::Base
      field   :is_axis_of_evil, :default => false
    end

## Defining Data

You can define data inside your class or outside.  For example, you might have a class like this:

    # app/models/country.rb
    class Country < ActiveHash::Base
    end

    # config/initializers/data.rb
    Country.data = [
        {:id => 1, :name => "US"},
        {:id => 2, :name => "Canada"}
    ]

If you prefer to store your data in YAML, see below.

## Class Methods

ActiveHash gives you ActiveRecord-esque methods like:

    Country.all             # => returns all Country objects
    Country.count           # => returns the length of the .data array
    Country.first           # => returns the first country object
    Country.last            # => returns the last country object
    Country.find 1          # => returns the first country object with that id
    Country.find [1,2]      # => returns all Country objects with ids in the array
    Country.find :all       # => same as .all
    Country.find :all, args # => the second argument is totally ignored, but allows it to play nicely with AR
    Country.find_by_id 1    # => find the first object that matches the id

It also gives you a few dynamic finder methods.  For example, if you defined :name as a field, you'd get:

    Country.find_by_name "foo"                    # => returns the first object matching that name
    Country.find_all_by_name "foo"                # => returns an array of the objects with matching names
    Country.find_by_id_and_name 1, "Germany"      # => returns the first object matching that id and name
    Country.find_all_by_id_and_name 1, "Germany"  # => returns an array of objects matching that name and id

## Instance Methods

ActiveHash objects implement enough of the ActiveRecord api to satisfy most common needs.  For example:

    Country#id          # => returns the id or nil
    Country#id=         # => sets the id attribute
    Country#quoted_id   # => returns the numeric id
    Country#to_param    # => returns the id as a string
    Country#new_record? # => returns true if is not part of Country.all, false otherwise
    Country#readonly?   # => true
    Country#hash        # => the hash of the id (or the hash of nil)
    Country#eql?        # => compares type and id, returns false if id is nil

ActiveHash also gives you methods related to the fields you defined.  For example, if you defined :name as a field, you'd get:

    Country#name        # => returns the passed in name
    Country#name?       # => returns true if the name is not blank
    Country#name=       # => sets the name

## Saving in-memory records

The ActiveHash::Base.all method functions like an in-memory data store.  You can save your records to the the .all array by using standard ActiveRecord create and save methods:

    Country.all             # => []
    Country.create
    Country.all             # [ <Country :id => 1> ]
    country = Country.new
    country.new_record?     # => true
    country.save
    country.new_record?     # => false
    Country.all             # [ <Country :id => 1>, <Country :id => 2>  ]

Notice that when adding records to the collection, it will auto-increment the id for you by default.  If you use string ids, it will not auto-increment the id.  Available methods are:

    Country.insert( record )
    Country#save
    Country#save!
    Country.create
    Country.create!

As such, ActiveHash::Base and its descendants should work with Fixjour or FactoryGirl, so you can treat ActiveHash records the same way you would any other ActiveRecord model in tests.

To clear all records from the in-memory array, call delete_all:

    Country.delete_all  # => does not affect the yaml files in any way - just clears the in-memory array which can be useful for testing

## Referencing ActiveHash objects from ActiveRecord Associations

One common use case for ActiveHash is to have top-level objects in memory that ActiveRecord objects belong to.

In versions of ActiveRecord previous to 3.1, you should be able to do the following:

    class Country < ActiveHash::Base
    end

    class Person < ActiveRecord::Base
      belongs_to :country
    end

However, as of ActiveRecord 3.1 support for ActiveRecord's `belong_to` is broken.  Instead, you must use the `belongs_to_active_hash` method:

    class Country < ActiveHash::Base
    end

    class Person < ActiveRecord::Base
      extend ActiveHash::Associations::ActiveRecordExtensions
      belongs_to_active_hash :country
    end

With ActiveRecord versions < 3.1, ActiveHash will also work as a polymorphic parent:

    class Country < ActiveHash::Base
    end

    class Person < ActiveRecord::Base
      belongs_to :location, :polymorphic => true
    end

    person = Person.new
    person.location = Country.first
    person.save
    person.location # => Country.first

However, as of ActiveRecord 3.1 this will not work.  If you need support for that, please open an issue.

You can also use standard rails view helpers, like #collection_select:

    <%= collection_select :person, :country_id, Country.all, :id, :name %>

### Using shortcuts

Since ActiveHashes usually are static, we can use shortcuts to assign via an easy to remember string instead of an obscure ID number.

    # app/models/country.rb
    class Country < ActiveHash::Base
    end

    # app/models/person.rb
    class Person < ActiveRecord::Base
      extend ActiveHash::Associations::ActiveRecordExtensions
      belongs_to_active_hash :country, :shortcuts => [:name]
    end

    # config/initializers/data.rb
    Country.data = [
        {:id => 1, :name => "US"},
        {:id => 2, :name => "Canada"}
    ]

    # Using `rails console`
    john = Person.new
    john.country_name = "US"
    # Is the same as doing `john.country = Country.find_by_name("US")`
    john.country_name
    # Will return "US", and is the same as doing `john.country.try(:name)`

You can have multiple shortcuts, so settings `:shortcuts => [:name, :friendly_name]` will enable you to use `#country_name=` and `#country_friendly_name=`.

## Referencing ActiveRecord objects from ActiveHash

If you include the ActiveHash::Associations module, you can also create associations from your ActiveHash classes, like so:

    class Country < ActiveHash::Base
      include ActiveHash::Associations
      has_many :people
    end

    class Person < ActiveHash::Base
      include ActiveHash::Associations
      belongs_to :country
      has_many :pets
    end

    class Pet < ActiveRecord::Base
    end

Once you define a belongs to, you also get the setter method:

    class City < ActiveHash::Base
      include ActiveHash::Associations
      belongs_to :state
    end

    city = City.new
    city.state = State.first
    city.state_id             # is State.first.id

NOTE:  You cannot use ActiveHash objects as children of ActiveRecord and I don't plan on adding support for that.  It doesn't really make any sense, since you'd have to hard-code your database ids in your class or yaml files, which is a dependency inversion.

Thanks to baldwindavid for the ideas and code on that one.

## ActiveYaml

If you want to store your data in YAML files, just inherit from ActiveYaml and specify your path information:

    class Country < ActiveYaml::Base
    end

By default, this class will look for a yml file named "countries.yml" in the same directory as the file.  You can either change the directory it looks in, the filename it looks for, or both:

    class Country < ActiveYaml::Base
      set_root_path "/u/data"
      set_filename "sample"
    end

The above example will look for the file "/u/data/sample.yml".

Since ActiveYaml just creates a hash from the YAML file, you will have all fields specified in YAML auto-defined for you.  You can format your YAML as an array, or as a hash:

    # array style
    - id: 1
      name: US
    - id: 2
      name: Canada
    - id: 3
      name: Mexico

    # hash style
    us:
      id: 1
      name: US
    canada:
      id: 2
      name: Canada
    mexico:
      id: 3
      name: Mexico

### Using aliases in YAML

Aliases can be used in ActiveYaml using either array or hash style by including `ActiveYaml::Aliases`.
With that module included, keys beginning with a '/' character can be safely added, and will be ignored, allowing you to add aliases anywhere in your code:

    # Array Style
    - /aliases:
      soda_flavor: &soda_flavor
        sweet
      soda_price: &soda_price
        1.0

    - id: 1
      name: Coke
      flavor: *soda_flavor
      price: *soda_price


     # Key style
    /aliases:
      soda_flavor: &soda_flavor
        sweet
      soda_price: &soda_price
        1.0

    coke:
      id: 1
      name: Coke
      flavor: *soda_flavor
      price: *soda_price

    class Soda < ActiveYaml::Base
      include ActiveYaml::Aliases
    end

    Soda.length # => 1
    Soda.first.flavor # => sweet
    Soda.first.price # => 1.0


## ActiveFile

If you store encrypted data, or you'd like to store your flat files as CSV or XML or any other format, you can easily include ActiveHash to parse and load your file.  Just add a custom ::load_file method, and define the extension you want the file to use:

    class Country < ActiveFile::Base
      set_root_path "/u/data"
      set_filename "sample"

      class << self
        def extension
          ".super_secret"
        end

        def load_file
          MyAwesomeDecoder.load_file(full_path)
        end
      end
    end

The two methods you need to implement are load_file, which needs to return an array of hashes, and .extension, which returns the file extension you are using.  You have full_path available to you if you wish, or you can provide your own path.

Setting the default file location in Rails:

    # config/initializers/active_file.rb
    ActiveFile::Base.set_root_path "config/activefiles"

In Rails, in development mode, it reloads the entire class, which reloads the file.  In production, the data cached in memory.

NOTE:  By default, .full_path refers to the current working directory.  In a rails app, this will be RAILS_ROOT.

## Enum

ActiveHash can expose its data in an Enumeration by setting constants for each record. This allows records to be accessed in code through a constant set in the ActiveHash class.

The field to be used as the constant is set using _enum_accessor_ which takes the name of a field as an argument.

    class Country < ActiveHash::Base
      include ActiveHash::Enum
      self.data = [
          {:id => 1, :name => "US", :capital => "Washington, DC"},
          {:id => 2, :name => "Canada", :capital => "Ottawa"},
          {:id => 3, :name => "Mexico", :capital => "Mexico City"}
      ]
      enum_accessor :name
    end

Records can be accessed by looking up the field constant:

    >> Country::US.capital
    => "Washington DC"
    >> Country::MEXICO.id
    => 3
    >> Country::CANADA
    => #<Country:0x10229fb28 @attributes={:name=>"Canada", :id=>2}

You may also use multiple attributes to generate the constant, like so:

    class Town < ActiveHash::Base
      include ActiveHash::Enum
      self.data = [
          {:id => 1, :name => "Columbus", :state => "NY"},
          {:id => 2, :name => "Columbus", :state => "OH"}
      ]
      enum_accessor :name, :state
    end

    >> Town::COLUMBUS_NY
    >> Town::COLUMBUS_OH

Constants are formed by first stripping all non-word characters and then upcasing the result. This means strings like "Blazing Saddles", "ReBar", "Mike & Ike" and "Ho! Ho! Ho!" become BLAZING_SADDLES, REBAR, MIKE_IKE and HO_HO_HO.

The field specified as the _enum_accessor_ must contain unique data values.

## Contributing

If you'd like to become an ActiveHash contributor, the easiest way it to fork this repo, make your changes, run the specs and submit a pull request once they pass.

To run specs, run:

    bundle install
    bundle exec rspec spec

If your changes seem reasonable and the specs pass I'll give you commit rights to this repo and add you to the list of people who can push the gem.

## Releasing a new version

To make users' lives easier, please maintain support for:

  * Ruby 1.8.7
  * Ruby Enterprise 1.8.7
  * Ruby 1.92
  * ActiveRecord/ActiveSupport from 2.3.2 through edge

To that end, run specs against all rubies before committing:

    rake appraisal:install
    rake appraisal spec

Once appraisal passes in all supported rubies, follow these steps to release a new version of active_hash:

  * update the changelog with a brief summary of the changes that are included in the release
  * bump the gem version by editing the `version.rb` file
  * if there are new contributors, add them to the list of authors in the gemspec
  * run `rake build`
  * commit those changes
  * run `rake install` and verify that the gem loads correctly from an irb session
  * run `rake release`, which will rebuild the gem, tag it, push the tags (and your latest commit) to github, then push the gem to rubygems.org

If you have any questions about how to maintain backwards compatibility, please email me and we can figure it out.

## Copyright

Copyright (c) 2010 Jeff Dean. See LICENSE for details.
