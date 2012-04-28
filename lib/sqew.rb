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

require 'forwardable'

module Sqew
  module ClassMethods
    extend Forwardable

    def qu
      Qu
    end
    
    def_delegators :qu, :backend, :backend=, :enqueue, :length, :queues, :reserve, :clear
  end
  extend ClassMethods

  class << self
    def configure(*args, &block)
      self.backend = Sqew::Backend::LevelDB.new
      Qu.configure(*args, &block)
    end
  end

  extend SingleForwardable
  def_delegators :backend, :failed_jobs, :running_jobs
end
