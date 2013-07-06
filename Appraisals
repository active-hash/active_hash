# -*- ruby -*-

require "util/ruby_version"

versions = %w[3.0 3.1 3.2]
versions.unshift "2.3" if RubyVersion <= '1.9.3'
versions.unshift "2.2" if RubyVersion.is? '1.8'
versions << '4.0' if RubyVersion.is? >= '1.9.3'

versions.each do |version|
  appraise "rails-#{version}" do
    gem "activerecord", "~> #{version}.0"
  end
end