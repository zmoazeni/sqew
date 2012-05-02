require "spec_helper"

describe Sqew::Backend::LevelDB do
  before do
    @backend = Sqew::Backend::LevelDB.new()
    @backend.connection = DB_PATH
  end

  it "should report queued jobs" do
    Timecop.freeze(Time.utc(2012, 5, 2)) { @backend.enqueue(Qu::Payload.new(:klass => TestJob, :args => 1)) }
    Timecop.freeze(Time.utc(2012, 5, 3)) { @backend.enqueue(Qu::Payload.new(:klass => TestJob, :args => 2)) }
    Timecop.freeze(Time.utc(2012, 5, 1)) { @backend.enqueue(Qu::Payload.new(:klass => TestJob, :args => 3)) }
    @backend.queued_jobs.should == [
                                    {"klass"=>"TestJob", "args"=>3, "id" => "1335830400.0"},
                                    {"klass"=>"TestJob", "args"=>1, "id" => "1335916800.0"},
                                    {"klass"=>"TestJob", "args"=>2, "id" => "1336003200.0"}
                                   ]
  end

  it "should report the failed jobs" do
    error1 = double("error1", :message => "some error1", :backtrace => ["backtrace1"])
    error2 = double("error2", :message => "some error2", :backtrace => ["backtrace2"])
    error3 = double("error3", :message => "some error3", :backtrace => ["backtrace3"])
    
    @backend.failed(Qu::Payload.new(:klass => TestJob, :args => 1, :id => "2"), error2)
    @backend.failed(Qu::Payload.new(:klass => TestJob, :args => 1, :id => "3"), error3)
    @backend.failed(Qu::Payload.new(:klass => TestJob, :args => 1, :id => "1"), error1)

    @backend.failed_jobs.should == [
                                    {"klass"=>"TestJob", "args"=>1, "id" => "1", "error" => "some error1", "backtrace" => "backtrace1"},
                                    {"klass"=>"TestJob", "args"=>1, "id" => "2", "error" => "some error2", "backtrace" => "backtrace2"},
                                    {"klass"=>"TestJob", "args"=>1, "id" => "3", "error" => "some error3", "backtrace" => "backtrace3"}
    ]
    
  end

  it "should report running jobs" do
    Timecop.freeze(Time.utc(2012, 5, 2)) { @backend.enqueue(Qu::Payload.new(:klass => TestJob, :args => 1)) }
    Timecop.freeze(Time.utc(2012, 5, 3)) { @backend.enqueue(Qu::Payload.new(:klass => TestJob, :args => 2)) }

    job = @backend.reserve(nil)
    @backend.queued_jobs.should == [{"klass"=>"TestJob", "args"=>2, "id" => "1336003200.0"}]
    @backend.running_jobs.should == [{"klass"=>"TestJob", "args"=>1, "id" => "1335916800.0"}]
  end
end
