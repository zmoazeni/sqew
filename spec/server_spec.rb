require "spec_helper"

describe Sqew::Server do
  before do
    @old_backend = Sqew.backend
    Sqew.backend = Sqew::Backend::Immediate.new
    
    @manager = Sqew::Manager.new(3)
    Artifice.activate_with(Sqew::Server.new(@manager))
  end

  after do
    Artifice.deactivate
    Sqew.backend = @old_backend
  end
  
  it "enqueues jobs" do
    TestJob.testing.should == 0
    Sqew.push("TestJob", 15)
    TestJob.testing.should == 15
  end

  it "allows pings" do
    response = Sqew.ping
    response.code.should == "200"
  end

  it "returns the status" do
    status = Sqew.status
    status.should == {"queued" => [], "running" => [], "failed" => [], "workers" => 3}
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

  it "should allow queues to be cleared" do
    Qu.should_receive(:clear).with("queued", "failed")
    Sqew.clear("queued", "failed")
  end
  
  it "should allow all queues to be cleared" do
    Qu.should_receive(:clear).with()
    Sqew.clear
  end

  it "should allow jobs to be deleted" do
    Qu.backend.should_receive(:delete).with("10")
    Sqew.delete("10")
  end
end
