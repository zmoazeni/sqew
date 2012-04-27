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
    Artifice.activate_with(Smallq::Server.new)
  end

  after do
    Artifice.deactivate
  end
  
  it "enqueues jobs" do
    json = MultiJson.dump({job:"TestingServerJob", args:15})
    HTTParty.post("#{@url}/enqueue", body:json)
    TestingServerJob.testing.should == 15
  end

  it "allows pings" do
    response = HTTParty.get("#{@url}/ping")
    response.code.should == 200
  end
end
