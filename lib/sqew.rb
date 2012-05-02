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

    attr_accessor :server

    def qu
      Qu
    end

    def server=(raw)
      uri = URI.parse(raw)
      @http = Net::HTTP.new(uri.host, uri.port)
      @server = raw
    end
    
    def_delegators :qu, :connection, :connection=, :backend, :backend=, :length, :queues, :reserve, :clear, :logger, :logger=, :failure, :failure=
  end
  extend ClassMethods

  class << self
    def configure(*args, &block)
      self.backend = Sqew::Backend::LevelDB.new
      block.call(self)
      self.server ||= "http://0.0.0.0:9962"
    end

    def enqueue(job, *args)
      request = Net::HTTP::Post.new("/enqueue")
      request.body = MultiJson.encode("job" => job, "args" => args)
      @http.request(request)
    end

    def ping
      request = Net::HTTP::Get.new("/ping")
      @http.request(request)
    end

    def status
      request = Net::HTTP::Get.new("/status")
      response = @http.request(request)
      if response.code == "200"
        MultiJson.decode(@http.request(request).body)
      else
        raise "Error connecting to server #{response.code}:#{response.body}"
      end
    end

    def set_workers(count)
      request = Net::HTTP::Put.new("/workers")
      request.body = count.to_s
      @http.request(request)
    end
    alias_method :workers=, :set_workers
  end

  extend SingleForwardable
  def_delegators :backend, :failed_jobs, :running_jobs, :queued_jobs
end
