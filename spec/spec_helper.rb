require "rspec"
require "smallq"
require "fileutils"
require "timeout"
require "artifice"

DB_PATH    = File.expand_path("./tmp/db", File.dirname(__FILE__))

Smallq.configure do |c|
  c.connection = DB_PATH
  c.logger.level = Logger::ERROR
end

RSpec.configure do |c|
  c.debug = true
end
