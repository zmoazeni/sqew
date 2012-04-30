require "qu"
require "leveldb"
require "sinatra"
require "thin"
require "httparty"
require "slave"
require "multi_json"

# extensions
%w(slave multi_json).each do |file|
  require File.expand_path("../ext/#{file}", File.dirname(__FILE__))
end

require "sqew/version"
require "sqew/worker"
require "sqew/manager"
require "sqew/server"
require "sqew/payload"
require "sqew/backend/leveldb"

require 'forwardable'

module Sqew
  module ClassMethods
    extend Forwardable

    def qu
      Qu
    end
    
    def_delegators :qu, :backend, :backend=, :enqueue, :length, :queues, :reserve, :clear, :logger
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
