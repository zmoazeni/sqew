module Sqew
  class Payload < Qu::Payload
    def perform_forked(pipe)
      klass.perform(*args)
      pipe.write(Marshal.dump([true, nil]))
    rescue Exception => e
      logger.fatal "Job #{self} failed"
      log_exception(e)
      pipe.write(Marshal.dump([false, e]))
    ensure
      pipe.close
    end
  end
end
