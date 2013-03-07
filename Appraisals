# -*- ruby -*-

versions = %w[2.3 3.0 3.1 3.2]
versions.unshift "2.2" if RUBY_VERSION =~ /1\.8/
versions.each do |version|
  appraise "rails-#{version}" do
    gem "activerecord", "~> #{version}.0"
  end
end

unless RUBY_VERSION =~ /1\.8/
   appraise "rails-edge" do
     gem "activerecord", :git => "https://github.com/rails/rails.git"
     gem "activesupport", :git => "https://github.com/rails/rails.git"
   end
end
