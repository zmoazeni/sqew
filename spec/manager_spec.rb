require "spec_helper"

describe Sqew::Manager do
  it "allows the server to be started and stopped" do
    manager = Sqew::Manager.new(9962)
    manager.start_server
    sleep 1
    response = Net::HTTP.get_response(URI.parse("http://0.0.0.0:9962/ping"))
    response.code.should == "200"

    manager.stop_server
    sleep 1
    expect { Net::HTTP.get_response(URI.parse("http://0.0.0.0:9962/ping")) }.to raise_error(SystemCallError) 
  end

  it "allows queues to be cleared" do
    Qu.enqueue(FailJob, -1)
    manager = Sqew::Manager.new
    manager.work_off
    Qu.enqueue(TestJob, 5)
    Qu.clear
    Sqew.queued_jobs.should == []
    Sqew.failed_jobs.should == []
  end

  it "allows queues to be cleared by name" do
    Qu.enqueue(FailJob, -1)
    manager = Sqew::Manager.new
    manager.work_off
    Qu.enqueue(TestJob, 5)
    Qu.clear("failed")
    Sqew.queued_jobs.should_not == []
    Sqew.failed_jobs.should == []
  end
end
