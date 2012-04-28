require "spec_helper"

describe Sqew do
  it "allows jobs to be enqueued and worked" do
    TestJob.testing.should == 0
    Sqew.enqueue(TestJob, 20)
    manager = Sqew::Manager.new
    manager.work_off
    TestJob.testing.should == 20
    Sqew.running_jobs.should == []
  end

  it "reports the size of the queue" do
    Sqew.length.should == 0
    Sqew.enqueue(TestJob, 20)
    Sqew.length.should == 1
  end

  it "provides failed jobs" do
    Sqew.enqueue(FailJob, -1)
    manager = Sqew::Manager.new
    manager.work_off
    Sqew.failed_jobs.should == [{"klass"=>"FailJob", "args"=>[-1], "error"=>"failed in FailJob"}]
  end

  it "provides running jobs" do
    Sqew.enqueue(SlowJob, 10)
    manager = Sqew::Manager.new
    begin
      thread = Thread.new { manager.work_off }
      sleep 1
      Sqew.running_jobs.should == [{"klass"=>"SlowJob", "args"=>[10]}]
    ensure
      thread.terminate
    end
  end
end
