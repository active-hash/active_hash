# active_hash Changelog

## Version [3.1.1] - <sub><sup>2022-07-14</sup></sub>

  - Make scopes chainable [#248](https://github.com/active-hash/active_hash/pull/248) @andreynering
  - Set default key attributes [#251](https://github.com/active-hash/active_hash/pull/251/commits/68a0a121d110ac83f4bbf0024f027714fd24debf) @adampal
  - Migrate from Travis to GitHub Actions for CI @kbrock
  - Add primary_key support for has_one [#218](https://github.com/active-hash/active_hash/pull/218) @yujideveloper
  - Return a chainable relation when using .not [#205](https://github.com/active-hash/active_hash/pull/205) @pfeiffer
  - Correct fields with YAML aliases in array style [#226](https://github.com/active-hash/active_hash/pull/226) @stomk
  - Add ActiveHash::Relation#size method for compatibily [#227](https://github.com/active-hash/active_hash/pull/227) @sluceno
  - Implement ActiveRecord::RecordNotFound interface [#207](https://github.com/active-hash/active_hash/pull/207) @ChrisBr
  - Fix find_by_id with filter chain [#210](https://github.com/active-hash/active_hash/pull/210) @ChrisBr
  - Suppress Ruby 2.7 kwargs warnings [#206](https://github.com/active-hash/active_hash/pull/206) @yhirano55
  - Call reload if @records is not defined [#208](https://github.com/active-hash/active_hash/pull/208) @jonmagic
  - Switch to rspec3 (and update the Gemfile) [#209](https://github.com/active-hash/active_hash/pull/209) @djberg96
  - Implement filter by RegEx [#211](https://github.com/active-hash/active_hash/pull/211) @ChrisBr
  - Supports .pick method [#195](https://github.com/active-hash/active_hash/pull/195/files) @yhirano55
  - Lots of other small performance improvements, documentation and testing. Thanks to everyone who contributed!

## Version [3.1.0] - <sub><sup>2020-01-15</sup></sub>

  - Add ActiveHash::Base.order method inspired by ActiveRecord [#177](https://github.com/active-hash/active_hash/pull/177)
  - Add #to_ary to ActiveHash::Relation [#182](https://github.com/active-hash/active_hash/pull/182)
  - Allow #find to behave like Enumerable#find if id is nil and a block is given [#183](https://github.com/active-hash/active_hash/pull/183)
  - Delegate :sample to `records` [#189](https://github.com/active-hash/active_hash/pull/189)

## Version [3.0.0] - <sub><sup>2019-09-28</sup></sub>

  - Make #where chainable [#178](https://github.com/active-hash/active_hash/pull/178)

## Version [2.3.0] - <sub><sup>2019-09-28</sup></sub>

  - Add ::scope method (inspired by ActiveRecord) [#173](https://github.com/active-hash/active_hash/pull/173)
  - Let `.find(nil)` raise ActiveHash::RecordNotFound (inspired by ActiveRecord) [#174](https://github.com/active-hash/active_hash/pull/174)
  - `where` clause now works with range argument [#175](https://github.com/active-hash/active_hash/pull/175)

## Version [2.2.1] - <sub><sup>2019-03-06</sup></sub>

  - Allow empty YAML [#171](https://github.com/active-hash/active_hash/pull/171) Thanks, @ppworks

## Version [2.2.0] - <sub><sup>2018-11-22</sup></sub>

  - Support pluck method [#164](https://github.com/active-hash/active_hash/pull/164) Thanks, @ihatov08
  - Support where.not method [#167](https://github.com/active-hash/active_hash/pull/167) Thanks, @DialBird

## Version [2.1.0] - <sub><sup>2018-04-05</sup></sub>

  - Allow to use ERB (embedded ruby) in yml files [#160](https://github.com/active-hash/active_hash/pull/160) Thanks, @UgoMare
  - Add `ActiveHash::Base.polymorphic_name` [#162](https://github.com/active-hash/active_hash/pull/162)
  - Fix to be able to use enum accessor constant with same name as top-level constant[#161](https://github.com/active-hash/active_hash/pull/161) Thanks, @yujideveloper

## Version [2.0.0] - <sub><sup>2018-02-27</sup></sub>

  - Drop old Ruby and Rails support [#157](https://github.com/active-hash/active_hash/pull/157)
  - Don't generate instance accessors for class attributes [#136](https://github.com/active-hash/active_hash/pull/136) Thanks, @rainhead

## Version [1.5.3] - <sub><sup>2017-06-14</sup></sub>

  - Support symbol values in where and find_by [#156](https://github.com/active-hash/active_hash/pull/156) Thanks, @south37

## Version [1.5.2] - <sub><sup>2017-06-14</sup></sub>

  - Fix find_by when passed an invalid id [#152](https://github.com/active-hash/active_hash/pull/152) Thanks, @davidstosik

## Version [1.5.1] - <sub><sup>2017-04-20</sup></sub>

  - Fix a bug on `.where` [#147](https://github.com/active-hash/active_hash/pull/147)

## Version [1.5.0] - <sub><sup>2017-03-24</sup></sub>

  - add support for `.find_by!`(@syguer)

## Version [1.4.1] - <sub><sup>2015-09-13</sup></sub>

  - fix bug where `#attributes` didn't contain default values #107
  - add support for `.find_by` and `#_read_attribute`. Thanks, @andrewfader!

## Version [1.4.0] - <sub><sup>2014-09-03</sup></sub>

  - support Rails 4.2 (agraves, al2o3cr)

## Version [1.3.0] - <sub><sup>2014-02-18</sup></sub>

  - fix bug where including ActiveHash associations would make `belongs_to :imageable, polymorphic: true` blow up
  - fixed several bugs that prevented active hash from being used without active record / active model
  - add support for splitting up data sources into multiple files (rheaton)
  - add support for storing data in json files (rheaton)

## Version [1.2.3] - <sub><sup>2013-11-29</sup></sub>

  - fix bug where active hash would call `.all` on models when setting has_many (grosser)

## Version [1.2.2] - <sub><sup>2013-11-05</sup></sub>

  - fix bug in gemspec that made it impossible to use w/ Rails 4

## Version [1.2.1] - <sub><sup>2013-10-24</sup></sub>

  - fixed nasty bug in belongs_to that would prevent users from passing procs (thanks for the issue freebird0221)
  - fixed bug where passing in a separate class name to belongs_to_active_hash would raise an exception (mauriciopasquier)

## Version [1.2.0] - <sub><sup>2013-10-01</sup></sub>

  - belongs_to is back!
  - added support for primary key options for belongs_to (tomtaylor)

## Version [1.0.2] - <sub><sup>2013-09-09</sup></sub>

  - `where(nil)` returns all results, like ActiveRecord (kugaevsky)

## Version [1.0.1] - <sub><sup>2013-07-15</sup></sub>

  - Travis CI for ActiveHash + Ruby 2, 1.8.7, Rubinius and JRuby support (mattheworiordan)
  - no longer need to call .all before executing `find_by_*` or `where` methods (mattheworiordan)

## Version [1.0.0] - <sub><sup>2013-06-24</sup></sub>

  - save is a no-op on existing records, instead of raising an error (issue #63)

## Version [0.10.0] - <sub><sup>2013-06-24</sup></sub>

  - added ActiveYaml::Aliases module so you can DRY up your repetitive yaml (brett-richardson)

## Version [0.9.14] - <sub><sup>2013-05-23</sup></sub>

  - enum_accessor can now take multiple field names when generating the constant
  - temporarily disabled rails edge specs since there's an appraisal issue with minitest

2013-01-22
  - Fix find_by_id and find method returning nil unless .all called in ActiveYaml (mattheworiordan)

2012-07-25
  - Make find_by_id lookups faster by indexing records by id (desmondmonster)

2012-07-16
  - Validate IDs are unique by caching them in a set (desmondmonster)

2012-04-14
  - Support for has_one associations (kbrock)

2012-04-05
  - Allow gems like simple_form to read metadata about belongs_to associations that point to active hash objects (kbrock)

2012-01-19
  - Move specs to appraisal (flavorjones)

## Version [0.9.8] - <sub><sup>2012-01-18</sup></sub>

  - Make ActiveHash.find with array raise an exception when record cannot be found (mocoso)

## Version [0.9.7] - <sub><sup>2011-09-18</sup></sub>

  - Fixing the setting of a belongs_to_active_hash association by association (not id).

2011-08-31
  - added a module which adds a .belongs_to_active_hash method to ActiveRecord, since it was broken for Rails 3.1 (thanks to felixclack for pointing this issue out)

2011-06-07
  - fixed bug where .find would not work if you defined your ids as strings

2011-06-05
  - fixed deprecation warnings for class_inheritable_accessor (thanks scudco!)
  - added basic compatibility with the `where` method from Arel (thanks rgarver!)

2011-04-19
  - better dependency management and compatibility with ActiveSupport 2.x (thanks vandrijevik!)

2011-01-22
  - improved method_missing errors for dynamic finders
  - prevent users from trying to overwrite :attributes (https://github.com/active-hash/active_hash/issues/#issue/33)

2010-12-08
  - ruby 1.9.2 compatibility

2010-12-06
  - added dependency on ActiveModel
  - add persisted? method to ActiveHash::Base
  - ActiveHash::Base#save takes *args to be compatible with ActiveModel
  - ActiveHash::Base#to_param returns nil if the object hasn't been saved

2010-11-09
  - Use Ruby's definition of "word character" (numbers, underscores) when forming ActiveHash::Enum constants (tstuart)

2010-11-07
  - Get ActiveHash::Associations to return a scope for has_many active record relationships (mocoso)

2010-10-20
  - Allow find_by_* methods to accept an options hash, so rails associations don't blow up

2010-10-07
  - Add conditions to ActiveHash#all (Ryan Garver)
  - Add #cache_key to ActiveHash::Base (Tom Stuart)
  - Add banged dynamic finder support to ActiveHash::Base (Tom Stuart)

2010-09-16
  - Enum format now uses underscores instead of removing all characters
  - Removed test dependency on acts_as_fu

2010-05-26
  - Silence metaclass deprecation warnings in active support 2.3.8

2010-05-04
  - When calling ActiveFile::Base.reload do not actually perform the reload if nothing has been modified unless you call reload(true) to force (Michael Schubert)

2010-04-25
  - When ActiveRecord model belongs_to an ActiveHash and the associated id is nil, returns nil instead of raising RecordNotFound (Jeremy Weiskotten)
  - Merged Nakajima's "add" alias for "create" - gotta save those ASCII characters :)

2010-03-01
  - Removed "extend"-related deprecations - they didn't play well with rails class loading

2010-01-18
  - Added stub for #destroyed? method, since Rails associations now depend on it

2009-12-19
  - Added ActiveHash::Enum (John Pignata)
  - Deprecated include ActiveHash::Associations in favor of extend ActiveHash::Associations
  - Fixed bug where you can't set nil to an association
  - Calling #belongs_to now creates the underlying field if it's not already there (belongs_to :city will create the :city_id field)

2009-12-10
  - Fixed a bug where belongs_to associations would raise an error instead of returning nil when the parent object didn't exist.
  - Added #[] and #[]= accessors for more ActiveRecord-esque-ness. (Pat Nakajima & Dave Yeu)

2009-12-01
  - Add marked_for_destruction? to be compatible with nested attributes (Brandon Keene)
  - Added second parameter to respond_to? and cleaned up specs (Brian Takita)
  - Find with an id that does not exist now raises a RecordNotFound exception to mimic ActiveRecord (Pat Nakajima)

2009-10-22
  - added setters to ActiveHash::Base for all fields
  - instantiating an ActiveHash object with a hash calls the setter methods on the object
  - boolean default values now work

2009-10-21
  - Removed auto-reloading of files based on mtime - maybe it will come back later
  - Made ActiveFile::Base.all a bit more sane

2009-10-13
  - added ActiveHash::Base.has_many, which works with ActiveRecord or ActiveHash classes (thanks to baldwindavid)
  - added ActiveHash::Base.belongs_to, which works with ActiveRecord or ActiveHash classes (thanks to baldwindavid)
  - added .delete_all method that clears the in-memory array
  - added support for Hash-style yaml (think, Rails fixtures)
  - added setter for parent object on belongs_to ( city = City.new; city.state = State.first; city.state_id == State.first.id )

2009-10-12
  - auto-assign fields after calling data= instead of after calling .all
  - remove require 'rubygems', so folks with non-gem setups can still use AH
  - added more specific activesupport dependency to ensure that metaclass is available
  - AH no longer calls to_i on ids.  If you pass in a string as an id, you'll get a string back
  - Fancy finders, such as find_all_by_id_and_name, will compare the to_s values of the fields, so you can pass in strings
  - You can now use ActiveHash models as the parents of polymorphic belongs_to associations
  - save, save!, create and create! now add items to the in-memory collection, and naively adds autoincrementing id
  - new_record? returns false if the record is part of the collection
  - ActiveHash now works with Fixjour!

2009-08-19
  - Added custom finders for multiple fields, such as .find_all_by_name_and_age

2009-07-23
  - Added support for auto-defining methods based on hash keys in ActiveHash::Base
  - Changed the :field and :fields API so that they don't overwrite existing methods (useful when ActiveHash auto-defines methods)
  - Fixed a bug where ActiveFile incorrectly set the root_path to be the path in the gem directory, not the current working directory

2009-07-24
  - ActiveFile no longer reloads files by default
  - Added ActiveFile.reload_active_file= so you can cause ActiveFile to reload
  - Setting data to nil correctly causes .all to return an empty array
  - Added reload(force) method, so that you can force a reload from files in ActiveFile, useful for tests

[HEAD]: https://github.com/active-hash/active_hash/compare/v4.3.0...HEAD
[4.3.0]: https://github.com/active-hash/active_hash/compare/v3.1.1...v4.3.0
[3.1.1]: https://github.com/active-hash/active_hash/compare/v3.1.0...v3.1.1
[3.1.0]: https://github.com/active-hash/active_hash/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/active-hash/active_hash/compare/v2.3.0...v3.0.0
[2.3.0]: https://github.com/active-hash/active_hash/compare/v2.2.1...v2.3.0
[2.2.1]: https://github.com/active-hash/active_hash/compare/v2.2.0...v2.2.1
[2.2.0]: https://github.com/active-hash/active_hash/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/active-hash/active_hash/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/active-hash/active_hash/compare/v1.5.3...v2.0.0
[1.5.3]: https://github.com/active-hash/active_hash/compare/v1.5.2...v1.5.3
[1.5.2]: https://github.com/active-hash/active_hash/compare/v1.5.1...v1.5.2
[1.5.1]: https://github.com/active-hash/active_hash/compare/v1.5.0...v1.5.1
[1.5.0]: https://github.com/active-hash/active_hash/compare/v1.4.1...v1.5.0
[1.4.1]: https://github.com/active-hash/active_hash/compare/v1.4.0...v1.4.1
[1.4.0]: https://github.com/active-hash/active_hash/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/active-hash/active_hash/compare/v1.2.3...v1.3.0
[1.2.3]: https://github.com/active-hash/active_hash/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/active-hash/active_hash/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/active-hash/active_hash/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/active-hash/active_hash/compare/v1.0.2...v1.2.0
[1.0.2]: https://github.com/active-hash/active_hash/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/active-hash/active_hash/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/active-hash/active_hash/compare/v0.10.0...v1.0.0
[0.10.0]: https://github.com/active-hash/active_hash/compare/v0.9.14...v0.10.0
[0.9.14]: https://github.com/active-hash/active_hash/compare/v0.9.8...v0.9.14
[0.9.8]: https://github.com/active-hash/active_hash/compare/v0.9.7...v0.9.8
[0.9.7]: https://github.com/active-hash/active_hash/compare/v0.9.6...v0.9.7
