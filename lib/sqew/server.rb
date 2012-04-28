module Sqew
  class Server < Sinatra::Base
    post "/enqueue" do
      request.body.rewind
      json = MultiJson.load(request.body)
      request.body.rewind

      Sqew.enqueue(json["job"], json["args"])
      [202, {"Content-Type" => "application/json"}, ""]
    end

    get "/ping" do
      [200, {}, ""]
    end
  end
end
