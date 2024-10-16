source "http://rubygems.org/"

gemspec

gem 'rspec', '~> 3.9'
gem 'rake'
gem 'test-unit'
gem 'json'

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter', '>= 1.3.6'
end

platforms :ruby do
  gem 'sqlite3', '~> 1.4', '< 2.0' # can allow 2.0 once Rails's sqlite adapter allows it
end

gem 'activerecord', '>= 6.1.0'
