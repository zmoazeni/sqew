require "spec_helper"

describe Sqew::Manager do
  it "allows the server to be started and stopped" do
    manager = Sqew::Manager.new(9962)
    manager.start_server
    sleep 1
    response = HTTParty.get("http://0.0.0.0:9962/ping")
    response.code.should == 200

    manager.stop_server
    sleep 1
    expect { HTTParty.get("http://0.0.0.0:9962/ping") }.to raise_error(SystemCallError) 
  end
end
