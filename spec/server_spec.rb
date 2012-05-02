require "spec_helper"

describe Sqew::Server do
  before do
    @old_backend = Sqew.backend
    Sqew.backend = Sqew::Backend::Immediate.new
    
    @url = "http://0.0.0.0"
    @manager = Sqew::Manager.new(3000, 3)
    Artifice.activate_with(Sqew::Server.new(@manager))
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
    MultiJson.decode(response.body).should == {"queued" => [], "running" => [], "failed" => [], "workers" => 3}
  end

  it "allows workers to be configured" do
    response = HTTParty.put("#{@url}/workers", :body => "5")
    response.code.should == 200
    @manager.max_workers.should == 5
  end

  it "allows workers to be paused" do
    HTTParty.put("#{@url}/workers", :body => "pause")
    @manager.max_workers.should == 0
    
    HTTParty.put("#{@url}/workers", :body => "resume")
    @manager.max_workers.should == 3
  end

  it "should remember the number of workers, even if paused multiple times" do
    HTTParty.put("#{@url}/workers", :body => "pause")
    HTTParty.put("#{@url}/workers", :body => "pause")
    HTTParty.put("#{@url}/workers", :body => "resume")
    @manager.max_workers.should == 3
  end
end
