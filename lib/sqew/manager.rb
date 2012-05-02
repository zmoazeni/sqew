module Sqew
  class Manager < Qu::Worker
    attr_accessor :max_workers
    
    def initialize(port = 3000, max_workers = 3)
      super([])
      @port = port
      @poll = 1
      @thin_server = nil
      @max_workers = max_workers

      @group = ThreadGroup.new
    end

    def start_server
      Thread.new do
        Thin::Logging.silent = true
        @thin_server = Thin::Server.new('0.0.0.0', @port, Server.new(self), {signals:false})
        @thin_server.start
      end
    end
    
    def stop_server
      @thin_server.stop
    end

    def handle_signals
      logger.debug "Worker #{id} registering traps for INT and TERM signals"
      %W(INT TERM).each do |sig|
        trap(sig) do
          logger.info "Worker #{id} received #{sig}, will wait for workers to finish then quit"
          @exiting = true
        end
      end
    end

    def start
      logger.warn "Worker #{id} starting"
      start_slave
      handle_signals
      start_server
      loop do
        work
        sleep @poll
        
        if @exiting
          stop_server
          @group.list.map {|t| t.join }
          Qu.backend.close
          stop_slave
          break
        end
      end
    ensure
      logger.debug "Worker #{id} done"
    end

    private
    def work
      if available?
        logger.debug "Worker #{id} waiting for next job"
        job = Qu.reserve(self)
        if job
          thread = Thread.new do
            begin
              logger.debug "Worker #{id}:#{Process.pid} reserved job #{job}"
              remote_thread = @worker.fork_job(job)
              success, error = remote_thread.value
              logger.debug "Worker #{id}:#{Process.pid} completed job #{job}"
              
              if success
                Qu.backend.completed(job)
              else
                Qu.failure.create(job, error) if Qu.failure
                Qu.backend.failed(job, error)
              end
            rescue Exception => e
              logger.error "Thread Error"
              log_exception(e)
            end              
          end
          @group.add(thread)
        end
      end
    end

    def available?
      @group.list.size < @max_workers
    end

    def start_slave
      trap("INT") { }
      @worker_server = Slave.new(:threadsafe => true) { Sqew::Worker.new }
      @worker = @worker_server.object
    end

    def stop_slave
      @worker_server.shutdown
    end
  end
end
