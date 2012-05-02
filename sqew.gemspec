# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sqew/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Zach Moazeni"]
  gem.email         = ["zach.moazeni@gmail.com"]
  gem.description   = "a lightweight background processor"
  gem.summary       = "sqew is a lightweight background processor. You start a single process that will act as a queue manager and will work multiple jobs concurrently.

sqew is not meant to be an all encompassing scalable solution. If you need more management over worker processes or need to split it among multiple machines, it's recommend to use other background processors such as resque, sidekiq, and qu"
  
  gem.homepage      = "https://github.com/zmoazeni/sqew"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sqew"
  gem.require_paths = ["lib"]
  gem.version       = Sqew::VERSION

  gem.add_dependency "leveldb-ruby", "~> 0.14"
  gem.add_dependency "qu", "~> 0.1"
  gem.add_dependency "multi_json", "~> 1.0"
  gem.add_dependency "sinatra", "~> 1.0"
  gem.add_dependency "thin", "~> 1.0"
  gem.add_dependency "httparty", "~> 0.8"
  gem.add_dependency "slave", "1.3"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "debugger"
  gem.add_development_dependency "artifice"
  gem.add_development_dependency "timecop"
end
