require "qu"
require "leveldb"
require "sinatra"
require "thin"
require "httparty"
require "multi_json"
require File.expand_path("../ext/multi_json", File.dirname(__FILE__))

require "sqew/version"
require "sqew/manager"
require "sqew/server"
require "sqew/backend/leveldb"

module Sqew
  class << self
    def configure(*args, &block)
      self.backend = Sqew::Backend::LevelDB.new
      Qu.configure(*args, &block)
    end

    def backend
      Qu.backend
    end

    def backend=(b)
      Qu.backend = b
    end

    def enqueue(*args)
      Qu.enqueue(*args)
    end
  end
end
