module Sqew
  class Manager < Qu::Worker
    def initialize(port=3000)
      super([])
      @port = port
      @poll = 1
      @thin_server = nil

      @max_children = 3
      @workers = []
      @lock = Mutex.new
      @group = ThreadGroup.new
    end

    def start_server
      Thread.new do
        Thin::Logging.silent = true
        @thin_server = Thin::Server.new('0.0.0.0', @port, Server.new, {signals:false})
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
          unless @forked
            logger.info "Worker #{id} received #{sig}, will wait for workers to finish then quit"
            @exiting = true
          end
        end
      end
    end

    def start
      logger.warn "Worker #{id} starting"
      handle_signals
      start_server
      loop do
        work
        sleep @poll
        
        if @exiting
          stop_server
          @group.list.map {|t| t.join }
          Qu.backend.close
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
          rd, wr = IO.pipe
          worker_pid = fork do
            srand
            @forked = true
            rd.close
            logger.debug "Worker #{id}:#{Process.pid} reserved job #{job}"
            job.perform_forked(wr)
            logger.debug "Worker #{id}:#{Process.pid} completed job #{job}"
          end

          add(worker_pid)
          thread = Thread.new do
            begin
              Process.wait(worker_pid)
              wr.close
              success, error = Marshal.load(rd.read)
              if success
                Qu.backend.completed(job)
              else
                Qu.failure.create(job, error) if Qu.failure
                Qu.backend.failed(job, error)
              end
            rescue => e
              logger.error "Thread Error"
              log_exception(e)
            ensure
              rd.close
              remove(worker_pid)
            end
          end
          @group.add(thread)
        end
      end
    end

    def available?
      @lock.synchronize { @workers.size < @max_children }
    end

    def add(pid)
      @lock.synchronize { @workers << pid }
    end

    def remove(pid)
      @lock.synchronize { @workers.delete(pid) }
    end
  end
end
