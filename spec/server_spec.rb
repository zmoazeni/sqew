require "spec_helper"

describe Smallq::Server do
  before do
    class TestingServerJob
      @testing = 0
      
      def self.perform(arg)
        @testing = arg
      end

      def self.testing
        @testing
      end
    end
  end
  
  it "enqueues jobs", server:true do
    json = MultiJson.dump({job:"TestingServerJob", args:15})
    HTTParty.post("#{SERVER_URL}/enqueue", body:json)
    TestingServerJob.testing.should == 15
  end
end
