require "qu"
require "leveldb"
require "sinatra/base"
require "thin"
require "multi_json"
require "slave"
require File.expand_path("../ext/slave", File.dirname(__FILE__))

require "sqew/version"
require "sqew/worker"
require "sqew/manager"
require "sqew/server"
require "sqew/payload"
require "sqew/backend/leveldb"

require "forwardable"
require "net/http"

module Sqew
  module ClassMethods
    extend Forwardable

    def qu
      Qu
    end
    
    def_delegators :qu, :backend, :backend=, :length, :queues, :reserve, :clear, :logger
  end
  extend ClassMethods

  class << self
    def configure(*args, &block)
      self.backend = Sqew::Backend::LevelDB.new
      Qu.configure(*args, &block)
    end

    def enqueue(job, *args)
      http = Net::HTTP.new("0.0.0.0")
      request = Net::HTTP::Post.new("/enqueue")
      request.body = MultiJson.encode("job" => job, "args" => args)
      http.request(request)
    end

    def ping
      http = Net::HTTP.new("0.0.0.0")
      request = Net::HTTP::Get.new("/ping")
      http.request(request)
    end

    def status
      http = Net::HTTP.new("0.0.0.0")
      request = Net::HTTP::Get.new("/status")
      http.request(request)
    end

    def set_workers(count)
      http = Net::HTTP.new("0.0.0.0")
      request = Net::HTTP::Put.new("/workers")
      request.body = count.to_s
      http.request(request)
    end
    alias_method :workers=, :set_workers
  end

  extend SingleForwardable
  def_delegators :backend, :failed_jobs, :running_jobs, :queued_jobs
end
