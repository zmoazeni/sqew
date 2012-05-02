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
      URI.parse(raw) # verify it's parsable
      @server = raw
    end
    
    def_delegators :qu, :backend, :backend=, :length, :queues, :reserve, :logger, :logger=, :failure, :failure=
  end
  extend ClassMethods

  class << self
    def configure(*args, &block)
      self.backend = Sqew::Backend::LevelDB.new
      block.call(self)
      self.server ||= "http://0.0.0.0:9962"
      self.db     ||= "/tmp/"
    end

    def http
      uri = URI.parse(server)
      @http ||= Net::HTTP.new(uri.host, uri.port)
    end

    def push(job, *args)
      request = Net::HTTP::Post.new("/enqueue")
      request.body = MultiJson.encode("job" => job.to_s, "args" => args)
      http.request(request)
    end
    alias_method :enqueue, :push

    def ping
      request = Net::HTTP::Get.new("/ping")
      http.request(request)
    end

    def status
      request = Net::HTTP::Get.new("/status")
      response = http.request(request)
      if response.code == "200"
        MultiJson.decode(http.request(request).body)
      else
        raise "Error connecting to server #{response.code}:#{response.body}"
      end
    end

    def set_workers(count)
      request = Net::HTTP::Put.new("/workers")
      request.body = count.to_s
      http.request(request)
    end
    alias_method :workers=, :set_workers

    def clear(*queues)
      request = Net::HTTP::Delete.new("/clear")
      request.body = queues.join(",")
      http.request(request)
    end

    def delete(id)
      request = Net::HTTP::Delete.new("/#{id}")
      http.request(request)
    end
  end

  extend SingleForwardable
  def_delegators :backend, :failed_jobs, :running_jobs, :queued_jobs, :db, :db=
end
