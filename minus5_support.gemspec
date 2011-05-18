require 'rake'

GEMSPEC = Gem::Specification.new do |spec| 

  spec.name = 'minus5_support' 
  spec.summary = "minus5 support libraries" 
  spec.description = "minus5 support libraries for building services, working with sql_server, ..."
  spec.version = File.read('VERSION').strip
  spec.author = 'Igor Anic' 
  spec.email = 'ianic@minus5.hr'
  
  spec.add_dependency('daemons'      , '~> 1.1.3')
  spec.add_dependency('activesupport', '~> 3.0.7')
  spec.add_dependency('tiny_tds'     , '= 0.4.5.rc3')
  
  spec.files = FileList['lib/*', 'lib/**/*', 'tasks/*' , 'bin/*', 'test/*','test/**/*', 'Rakefile'].to_a  

  spec.homepage = 'http://www.minus5.hr' 
  spec.test_files = FileList['test/*_test.rb'].to_a
end
