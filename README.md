# ActiveHash

ActiveHash is a simple base class that allows you to use a ruby hash as a readonly datasource for an ActiveRecord-like model.

ActiveHash assumes that every hash has an :id key, which is what you would probably store in a database.  This allows you to seemlessly upgrade from ActiveHash objects to full ActiveRecord objects without having to change any code in your app, or any foreign keys in your database.

It also allows you to use #belongs_to in your AR objects.

ActiveHash can also be useful to create simple test classes that run without a database - ideal for testing plugins or gems that rely on simple AR behavior, but don't want to deal with databases or migrations for the spec suite.

ActiveHash also ships with:

  * ActiveFile: a base class that will reload data from a flat file every time the flat file is changed
  * ActiveYaml: a base class that will turn YAML into a hash and load the data into an ActiveHash object

## Installation

    sudo gem install zilkey-active_hash

## Usage

To use ActiveHash, you need to:

 * Inherit from ActiveHash::Base
 * Define your data
 * (optionally) Define your fields and/or default values

A quick example would be:

    class Country < ActiveHash::Base
      field :name
      self.data = [
        {:id => 1, :name => "US"},
        {:id => 2, :name => "Canada"}
      ]
    end

## Auto-Defined fields

ActiveHash will auto-define all fields for you when you load the hash.  For example, if you have the following class:

    class CustomField < ActiveYaml::Base
      self.data = [
        {:custom_field_1 => "foo"},
        {:custom_field_2 => "foo"},
        {:custom_field_3 => "foo"}
      ]
    end

Once you call CustomField.all it will define methods for :custom_field_1, :custom_field_2 etc...

If you need the fields at load time, as opposed to after .all is called, you can also define them manually, like so:

    class CustomField < ActiveYaml::Base
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

    Country.find_by_name "foo"      # => returns the first object matching that name
    Country.find_all_by_name "foo"  # => returns an array of the objects with matching names

## Instance Methods

ActiveHash objects implement enough of the ActiveRecord api to satisfy most common needs.  For example:

    Country#id          # => returns the numeric id or nil
    Country#quoted_id   # => returns the numeric id
    Country#to_param    # => returns the id as a string
    Country#new_record? # => false
    Country#readonly?   # => true
    Country#hash        # => the hash of the id (or the hash of nil)
    Country#eql?        # => compares type and id, returns false if id is nil

ActiveHash also gives you methods related to the fields you defined.  For example, if you defined :name as a field, you'd get:

    Country#name        # => returns the passed in name
    Country#name?       # => returns true if the name is not blank

## Integration with Rails

You can create .belongs_to associations from rails objects, like so:

    class Country < ActiveHash::Base
    end

    class Person < ActiveRecord::Base
      belongs_to :country
    end

You can also use standard rails view helpers, like #collection_select:

    <%= collection_select :person, :country_id, Country.all, :id, :name %>

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

ActiveYaml, as well as ActiveFile, check the mtime of the file you specified, and reloads the data if the mtime has changed.  So you can replace the data in the files even if your app is running in production mode in rails.

Since ActiveYaml just creates a hash from the YAML file, you will have all fields specified in YAML auto-defined for you once you call all.

## ActiveFile

If you store encrypted data, or you'd like to store your flat files as CSV or XML or any other format, you can easily extend ActiveHash to parse and load your file.  Just add a custom ::load_file method, and define the extension you want the file to use:

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

NOTE:  By default, .full_path refers to the current working directory.  In a rails app, this will be RAILS_ROOT.

## Authors

Written by Mike Dalessio and Jeff Dean

## Development

The only thing I think I'd really like to add here is support for typecasting the fields.

== Copyright

Copyright (c) 2009 Jeff Dean. See LICENSE for details.
