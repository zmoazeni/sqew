module Sqew
  class Worker
    include Qu::Logger

    def fork_job(job)
      rd, wr = IO.pipe
      pid = fork do
        srand
        rd.close
        job.perform_forked(wr)
        # catch special exception and regular/internalXS ones
        # add logging to regular (internal)
      end

      Thread.new do
        begin
          Process.wait(pid)
          wr.close
          Marshal.load(rd.read)
        ensure
          rd.close
        end
      end
    end
  end
end
