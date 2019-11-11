# frozen_string_literal: true

begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

require "rdoc/task"

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title    = "PaywareConnect"
  rdoc.options << "--line-numbers"
  rdoc.rdoc_files.include("README.md")
  rdoc.rdoc_files.include("lib/**/*.rb")
end

APP_RAKEFILE = File.expand_path("../test/dummy/Rakefile", __FILE__)
load "rails/tasks/engine.rake"
load "rails/tasks/statistics.rake"
load "workarea/changelog.rake"

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = false
end

task default: :test

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "workarea/payware_connect/version"

desc "Release version #{Workarea::PaywareConnect::VERSION} of the gem"
task :release do
  host = "https://#{ENV['BUNDLE_GEMS__WEBLINC__COM']}@gems.weblinc.com"


  Rake::Task["workarea:changelog"].execute
  system "git add CHANGELOG.md"
  system 'git commit -m "Update CHANGELOG"'
  system "git push origin HEAD"

  system "git tag -a v#{Workarea::PaywareConnect::VERSION} -m 'Tagging #{Workarea::PaywareConnect::VERSION}'"
  system "git push --tags"

  system "gem build workarea-payware_connect.gemspec"
  system "gem push workarea-payware_connect-#{Workarea::PaywareConnect::VERSION}.gem --host #{host}"
  system "rm workarea-payware_connect-#{Workarea::PaywareConnect::VERSION}.gem"
end
