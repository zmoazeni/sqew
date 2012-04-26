# -*- encoding: utf-8 -*-
require File.expand_path('../lib/smallq/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Zach Moazeni"]
  gem.email         = ["zach.moazeni@gmail.com"]
  gem.description   = "a lightweight background processor"
  gem.summary       = %q{smallq is a lightweight background processor. You start a single process that will act as a queue manager and will work multiple jobs concurrently.

smallq is not meant to be an all encompassing scalable solution. If you need more management over worker processes or need to split it among multiple machiens, it's recommend to use other background processors such as resque, sidekiq, and qu
}
  gem.homepage      = "https://github.com/zmoazeni/smallq"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "smallq"
  gem.require_paths = ["lib"]
  gem.version       = Smallq::VERSION
end
