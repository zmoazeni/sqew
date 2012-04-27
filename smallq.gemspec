# -*- encoding: utf-8 -*-
require File.expand_path('../lib/smallq/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Zach Moazeni"]
  gem.email         = ["zach.moazeni@gmail.com"]
  gem.description   = "a lightweight background processor"
  gem.summary       = "smallq is a lightweight background processor. You start a single process that will act as a queue manager and will work multiple jobs concurrently.

smallq is not meant to be an all encompassing scalable solution. If you need more management over worker processes or need to split it among multiple machines, it's recommend to use other background processors such as resque, sidekiq, and qu"
  
  gem.homepage      = "https://github.com/zmoazeni/smallq"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "smallq"
  gem.require_paths = ["lib"]
  gem.version       = Smallq::VERSION

  gem.add_dependency "leveldb-ruby", "~> 0.14"
  gem.add_dependency "qu", "~> 0.1"
  gem.add_dependency "multi_json", "~> 1.0"
  gem.add_dependency "sinatra", "~> 1.0"
  gem.add_dependency "thin", "~> 1.0"
  gem.add_dependency "httparty", "~> 0.8"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "debugger"
end
