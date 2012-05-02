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
    Sqew.enqueue("TestJob", 15)
    TestJob.testing.should == 15
  end

  it "allows pings" do
    response = Sqew.ping
    response.code.should == "200"
  end

  it "returns the status" do
    response = Sqew.status
    response.code.should == "200"
    MultiJson.decode(response.body).should == {"queued" => [], "running" => [], "failed" => [], "workers" => 3}
  end

  it "allows workers to be configured" do
    response = Sqew.set_workers(5)
    response.code.should == "200"
    @manager.max_workers.should == 5

    Sqew.workers = 2
    @manager.max_workers.should == 2
  end

  it "allows workers to be paused" do
    Sqew.workers = :pause
    @manager.max_workers.should == 0
    
    Sqew.workers = :resume
    @manager.max_workers.should == 3
  end

  it "should remember the number of workers, even if paused multiple times" do
    Sqew.workers = :pause
    Sqew.workers = :pause
    Sqew.workers = :resume
    @manager.max_workers.should == 3
  end
end
