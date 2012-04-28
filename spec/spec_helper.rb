require "rspec"
require "sqew"
require "fileutils"
require "timeout"
require "artifice"
require "sqew/backend/immediate"

Dir[File.expand_path("support/*.rb", File.dirname(__FILE__))].each {|r| require r}

DB_PATH = File.expand_path("./tmp/", File.dirname(__FILE__))

Sqew.configure do |c|
  c.connection = DB_PATH
  c.logger.level = Logger::ERROR
end

RSpec.configure do |c|
  c.debug = true

  c.before do
    TestJob.reset
  end
end
