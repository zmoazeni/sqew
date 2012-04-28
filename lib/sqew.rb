require "qu"
require "leveldb"
require "multi_json"
require "sinatra"
require "thin"
require "httparty"

require "sqew/version"
require "sqew/worker"
require "sqew/server"

require "qu/backend/immediate"

module Sqew
  def self.configure(*args, &block)
    Qu.backend = Qu::Backend::Immediate.new
    Qu.configure(*args, &block)
  end
end
