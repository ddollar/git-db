require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "GitDB::Commands" do

  it "has a receive-pack command" do
    GitDB::Commands.commands['receive-pack'].should_not be_nil
  end

  it "has an upload-pack command" do
  end

  it "executes a command" do
    @command = mock
    @name    = 'command'
    @args    = ['Test Repository']

    GitDB::Commands.should_receive(:commands).at_least(:once).and_return({ @name => @command })
    @command.should_receive(:execute).with(@args)
    
    GitDB::Commands.execute(@name, @args)
  end

end
