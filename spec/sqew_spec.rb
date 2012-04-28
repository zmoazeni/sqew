require "spec_helper"

describe Sqew do
  it "allows jobs to be enqueued and worked" do
    TestJob.testing.should == 0
    Qu.enqueue(TestJob, 20)
    manager = Sqew::Manager.new
    manager.work_off
    TestJob.testing.should == 20
  end
end
