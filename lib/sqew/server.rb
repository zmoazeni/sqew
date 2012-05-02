module Sqew
  class Server < Sinatra::Base

    def initialize(manager)
      super
      @manager = manager
    end
    
    post "/enqueue" do
      begin
        request.body.rewind
        json = MultiJson.decode(request.body)
        request.body.rewind

        Sqew.enqueue(json["job"], json["args"])
        [202, {"Content-Type" => "application/json"}, ""]
      rescue Exception => e
        json = MultiJson.encode({"error" => "#{e.message}\n#{e.backtrace}"})
        [500, {"Content-Type" => "application/json"}, json]
      end
    end

    get "/status" do
      json = MultiJson.encode({
                                "queued" => Sqew.queued_jobs,
                                "failed" => Sqew.failed_jobs,
                                "running" => Sqew.running_jobs,
                                "workers" => @manager.max_workers
                              })
      [200, {"Content-Type" => "application/json"}, json]
    end

    get "/ping" do
      [200, {}, ""]
    end

    put "/workers" do
      b = request.body.read
      case b
      when "pause"
        @manager.pause_workers
      when "resume"
        @manager.resume_workers
      else
        @manager.max_workers = b.to_i
      end
      [200, {}, ""]
    end
  end
end
