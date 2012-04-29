module Sqew
  class Server < Sinatra::Base
    post "/enqueue" do
      begin
        request.body.rewind
        json = MultiJson.load(request.body)
        request.body.rewind

        Sqew.enqueue(json["job"], json["args"])
        [202, {"Content-Type" => "application/json"}, ""]
      rescue Exception => e
        json = MultiJson.dump({"error" => "#{e.message}\n#{e.backtrace}"})
        [500, {"Content-Type" => "application/json"}, json]
      end
    end

    get "/ping" do
      [200, {}, ""]
    end
  end
end
