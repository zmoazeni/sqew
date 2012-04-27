require "spec_helper"

describe Smallq::Server do
  before do
    class TestingServerJob
      @testing = 0
      
      def self.perform(arg)
        @testing = 1
        p "in job #{arg.inspect}"
      end

      def self.testing
        @testing
      end
    end
  end
  
  it "enqueues jobs", server:true do
    HTTParty.post("#{SERVER_URL}/enqueue", body:{job:"TestingServerJob", args:1})
    @worker.work_off
    TestingServerJob.testing.should == 1
  end
end
c
