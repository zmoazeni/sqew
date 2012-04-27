module Smallq
  class Server < Sinatra::Base
    post "/enqueue" do
      [202, {"Content-Type" => "application/json"}, ""]
    end

    get "/ping" do
      [200, {}, ""]
    end
  end
end
