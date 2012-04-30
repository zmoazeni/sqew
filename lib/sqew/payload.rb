module Sqew
  class Payload < Qu::Payload
    def perform_forked(pipe)
      klass.perform(*args)
      pipe.write(Marshal.dump([true, nil]))
    rescue Exception => e
      pipe.write(Marshal.dump([false, e]))
      raise e
      # raise special exception
    ensure
      pipe.close
    end
  end
end
