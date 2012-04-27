require "spec_helper"

class TestingServerJob
  @testing = 0
  
  def self.perform(arg)
    @testing = arg
  end

  def self.testing
    @testing
  end
end
    
describe Smallq::Server do
  before do
    @url = "http://0.0.0.0"
  end
  
  it "enqueues jobs" do
    Artifice.activate_with(Smallq::Server.new) do
      json = MultiJson.dump({job:"TestingServerJob", args:15})
      HTTParty.post("#{@url}/enqueue", body:json)
      TestingServerJob.testing.should == 15
    end
  end
end
