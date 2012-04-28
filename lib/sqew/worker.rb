module Sqew
  class Worker < Qu::Worker
    def initialize(port=3000)
      # TODO: come back and handle max_children and multiple queues
      super([])
      @port = port
    end

    def stop_server
      # TODO: safely stop the server
      p "in stop"
    end
    
    def start_server
      Thread.new do
        Thin::Logging.silent = true
        Thin::Server.start('0.0.0.0', @port, {signals:false}) do
          run Server.new
        end
      end
    end
  end
end

