require "qu/backend/immediate"

module Sqew
  module Backend
    class Immediate < Qu::Backend::Immediate
      def queued_jobs
        []
      end
      alias_method :running_jobs, :queued_jobs
      alias_method :failed_jobs, :queued_jobs
    end
  end
end

