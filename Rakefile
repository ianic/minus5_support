require "rake/testtask" 
require 'rake/gempackagetask' 
load 'minus5_support.gemspec'

task :default => [:test] 

Rake::TestTask.new do |test| 
  test.libs << "test" 
  test.test_files = Dir[ "test/test_*.rb" ] 
  test.verbose = true   
end 

Rake::GemPackageTask.new(GEMSPEC) do |pkg|
end
