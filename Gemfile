source "http://rubygems.org/"

gemspec

gem 'rspec', '~> 2.2.0'
gem 'wwtd'
gem 'rake'
gem 'test-unit'

if RUBY_VERSION < '2.0.0'
  gem 'json', '< 2.0.0'
else
  gem 'json'
end

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter', '>= 1.3.6'
end

platforms :ruby do
  gem 'sqlite3'
end

gem 'activerecord', '>= 2.2.2'
