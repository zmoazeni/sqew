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
    failed = Sqew.failed_jobs
    failed.size.should == 1
    failed[0]["klass"].should == "FailJob"
  end

  it "provides running jobs" do
    Sqew.enqueue(SlowJob, 10)
    manager = Sqew::Manager.new
    begin
      thread = Thread.new { manager.work_off }
      sleep 1
      running = Sqew.running_jobs
      running.size.should == 1
      running[0]["klass"].should == "SlowJob"
    ensure
      thread.terminate
    end
  end
end
