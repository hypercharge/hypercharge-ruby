require "bundler/gem_tasks"
require "rake/testtask"
require "rdoc/task"

desc "Run the unit test suite"
task :default => 'test:units'

namespace :test do

  Rake::TestTask.new(:units) do |t|
    t.pattern = 'test/unit/**/*_spec.rb'
    t.ruby_opts << '-rubygems'
    t.libs << 'test'
    t.verbose = true
  end

  Rake::TestTask.new(:integration) do |t|
    t.pattern = 'test/integration/**/*_spec.rb'
    t.ruby_opts << '-rubygems'
    t.libs << 'test'
    t.verbose = true
  end
end