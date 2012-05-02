require "spec_helper"

describe Sqew::Server do
  before do
    @old_backend = Sqew.backend
    Sqew.backend = Sqew::Backend::Immediate.new
    
    @url = "http://0.0.0.0"
    Artifice.activate_with(Sqew::Server.new)
  end

  after do
    Artifice.deactivate
    Sqew.backend = @old_backend
  end
  
  it "enqueues jobs" do
    TestJob.testing.should == 0
    json = MultiJson.encode({job:"TestJob", args:15})
    HTTParty.post("#{@url}/enqueue", body:json)
    TestJob.testing.should == 15
  end

  it "allows pings" do
    response = HTTParty.get("#{@url}/ping")
    response.code.should == 200
  end

  it "returns the status" do
    response = HTTParty.get("#{@url}/status")
    response.code.should == 200
    json = MultiJson.decode(response.body)
    json["queued"].should == []
    json["running"].should == []
    json["failed"].should == []
  end
  
end
