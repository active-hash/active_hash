source :gemcutter

gemspec

group :development do
  activerecord_version = ENV['ACTIVE_HASH_ACTIVERECORD_VERSION']

  if activerecord_version == "edge"
    git "git://github.com/rails/rails.git" do
      gem "activerecord"
      gem "activesupport"
    end
  elsif activerecord_version && activerecord_version.strip != ""
    gem "activerecord", activerecord_version
  else
    gem "activerecord"
  end

  gem "rake", "0.8.7"
  gem "rspec", "2.2.0"
  gem "sqlite3-ruby", ">= 1.3.2"
end
