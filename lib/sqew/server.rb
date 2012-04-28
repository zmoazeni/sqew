module Sqew
  class Server < Sinatra::Base
    post "/enqueue" do
      request.body.rewind
      json = MultiJson.respond_to?(:adapter) ? MultiJson.load(request.body) : MultiJson.decode(request.body)
      request.body.rewind

      Qu.enqueue(json["job"], json["args"])
      [202, {"Content-Type" => "application/json"}, ""]
    end

    get "/ping" do
      [200, {}, ""]
    end
  end
end
