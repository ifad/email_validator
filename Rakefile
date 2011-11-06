require 'rake'
require 'rake/testtask'
require 'rdoc/task'

require 'pathname'

desc 'Default: run unit tests.'
task :default => [:clean, :test]

desc 'Remove the old log file'
task :clean do
  Pathname(__FILE__).dirname.join('test', 'debug.log').unlink rescue nil
end

desc 'Test the email validator.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the email validator.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'email_validator'
  rdoc.options << '--line-numbers --inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('TODO')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
