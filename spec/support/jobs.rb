class TestJob
  @testing = 0

  class << self
    def perform(arg)
      @testing = arg
    end

    def testing
      @testing
    end

    def reset
      @testing = 0
    end
  end
end

class FailJob
  def self.perform(*)
    raise "failed in FailJob"
  end
end
