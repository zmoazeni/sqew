require "rspec"
require "sqew"
require "fileutils"
require "timeout"
require "artifice"
require "timecop"
require "sqew/backend/immediate"

Dir[File.expand_path("support/*.rb", File.dirname(__FILE__))].each {|r| require r}

DB_PATH = File.expand_path("./tmp/db", File.dirname(__FILE__))

Sqew.configure do |c|
  c.db = DB_PATH
  c.logger.level = Logger::UNKNOWN
end

RSpec.configure do |c|
  c.debug = true

  c.before do
    Sqew.backend.close
    FileUtils.rm_rf(DB_PATH)
    FileUtils.mkdir_p(DB_PATH)
    TestJob.reset
    Timecop.return
  end
end

def save_and_open_page(response)
  filename = File.expand_path("tmp/#{Digest::SHA1.hexdigest(Time.now.to_f.to_s)}.html", File.dirname(__FILE__)) 
  File.open(filename, "w") do |file|
    file << response.body
  end
  `open #{filename}`
end
