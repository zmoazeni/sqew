require "rspec"
require "sqew"
require "fileutils"
require "timeout"
require "artifice"
require "sqew/backend/immediate"

Dir[File.expand_path("support/*.rb", File.dirname(__FILE__))].each {|r| require r}

DB_PATH = File.expand_path("./tmp/db", File.dirname(__FILE__))

Sqew.configure do |c|
  c.connection = DB_PATH
  c.logger.level = Logger::UNKNOWN
end

RSpec.configure do |c|
  c.debug = true

  c.before do
    FileUtils.rm_rf(DB_PATH)
    FileUtils.mkdir_p(DB_PATH)
    TestJob.reset
  end
end
