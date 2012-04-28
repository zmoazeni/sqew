module Sqew
  class Manager < Qu::Worker
    def initialize(port=3000)
      # TODO: come back and handle max_children and multiple queues
      super([])
      @port = port
      @thin_server = nil
    end

    def stop_server
      @thin_server.stop
    end
    
    def start_server
      Thread.new do
        Thin::Logging.silent = true
        @thin_server = Thin::Server.new('0.0.0.0', @port, Server.new, {signals:false})
        @thin_server.start
      end
    end
  end
end

