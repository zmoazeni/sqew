require "spec_helper"

describe Sqew::Server do
  before do
    @url = "http://0.0.0.0"
    Artifice.activate_with(Sqew::Server.new)
  end

  after do
    Artifice.deactivate
  end
  
  it "enqueues jobs" do
    TestJob.testing.should == 0
    json = MultiJson.dump({job:"TestJob", args:15})
    HTTParty.post("#{@url}/enqueue", body:json)
    TestJob.testing.should == 15
  end

  it "allows pings" do
    response = HTTParty.get("#{@url}/ping")
    response.code.should == 200
  end
end
