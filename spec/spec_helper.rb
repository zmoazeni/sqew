require "rspec"
require "smallq"
require "fileutils"
require "timeout"

TEST_PORT  = 9872
SERVER_URL = "http://0.0.0.0:#{TEST_PORT}"
DB_PATH    = File.expand_path("./tmp/db", File.dirname(__FILE__))

Smallq.configure do |c|
  c.connection = DB_PATH
  c.logger.level = Logger::ERROR
end

RSpec.configure do |c|
  c.debug = true
  
  c.before(:each, server:true) do
    FileUtils.rm_rf(DB_PATH)
    @worker = Smallq::Worker.new(TEST_PORT)
    # @_worker.start
    @worker.start_server
    wait_for_server("#{SERVER_URL}/ping")
  end

  c.after(:each, server:true) do
    @worker.stop_server
  end
end

def wait_for_server(url)
  Timeout.timeout(5) do
    loop do
      begin
        response = HTTParty.get(url)
        break if response.success?
      rescue SystemCallError
      end
    end
  end
end
