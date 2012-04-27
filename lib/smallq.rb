require "qu"
require "leveldb"
require "multi_json"
require "sinatra"
require "thin"
require "httparty"

require "smallq/version"
require "smallq/worker"
require "smallq/server"

require "qu/backend/immediate"

module Smallq
  def self.configure(*args, &block)
    Qu.backend = Qu::Backend::Immediate.new
    Qu.configure(*args, &block)
  end
end
