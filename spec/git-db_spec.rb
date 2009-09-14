require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "GitDB" do

  it "has a logger that can respond to puts" do
    GitDB.logger.should respond_to(:puts)
  end

  it "logs messages sent to log" do
    @logger  = mock
    @message = "Log This"

    GitDB.should_receive(:logger).and_return(@logger)
    @logger.should_receive(:puts).with(@message)

    GitDB.log(@message)
  end
end
