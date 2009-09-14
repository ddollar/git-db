require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "GitDB::Protocol" do

  describe "initialize with defaults" do
    before(:each) do
      @protocol = GitDB::Protocol.new
    end

    it "uses STDIN and STDOUT when no io is specified" do
      @protocol.reader.should == STDIN
      @protocol.writer.should == STDOUT
    end
  end

  describe "initialize with io" do
    before(:each) do
      @io       = StringIO.new
      @protocol = GitDB::Protocol.new(@io)
    end

    it "sets both reader and writer to the io" do
      @protocol.reader.should == @io
      @protocol.writer.should == @io
    end
  end

  describe "flush" do
    before(:each) do
      @io       = StringIO.new
      @protocol = GitDB::Protocol.new(@io)
    end

    it "can flush the writer" do
      @io.should_receive(:flush)
      @protocol.flush
    end
  end

  describe "read_command" do
    describe "valid command" do
      before(:each) do
        @io       = StringIO.new("000bcommand")
        @protocol = GitDB::Protocol.new(@io)
      end

      it "reads the command" do
        @protocol.read_command.should == 'command'
      end
    end

    describe "eof" do
      before(:each) do
        @io       = StringIO.new("0000")
        @protocol = GitDB::Protocol.new(@io)
      end

      it "returns nil" do
        @protocol.read_command.should be_nil
      end
    end
  end

  describe "write_command" do
    before(:each) do
      @io       = StringIO.new
      @protocol = GitDB::Protocol.new(@io)
    end

    it "writes a command" do
      @protocol.write_command('command')
      @io.string.should == '000bcommand'
    end
  end

  describe "write" do
    before(:each) do
      @io       = StringIO.new
      @protocol = GitDB::Protocol.new(@io)
      @data     = "test data"
    end

    it "can write" do
      @io.should_receive(:write).with(@data)
      @protocol.write(@data)
    end

    it "flushes after write" do
      @io.should_receive(:flush)
      @protocol.write(@data)
    end
  end

  describe "write_eof" do
    before(:each) do
      @io       = StringIO.new
      @protocol = GitDB::Protocol.new(@io)
    end

    it "writes eof" do
      @io.should_receive(:write).with("0000")
      @protocol.write_eof
    end
  end

  describe "read_pack" do
    before(:each) do
      @io       = StringIO.new
      @protocol = GitDB::Protocol.new(@io)
      @pack     = mock(GitDB::Pack)
    end

    it "uses GitDB::Pack to read a pack object" do
      GitDB::Pack.should_receive(:new).with(@io).and_return(@pack)
      @pack.should_receive(:read)
      @protocol.read_pack
    end
  end

  describe "write_pack" do
    before(:each) do
      @io       = StringIO.new
      @protocol = GitDB::Protocol.new(@io)
      @pack     = mock(GitDB::Pack)
      @entries  = []
    end

    it "uses GitDB::Pack to write a pack object" do
      GitDB::Pack.should_receive(:new).with(@io).and_return(@pack)
      @pack.should_receive(:write).with(@entries)
      @protocol.write_pack(@entries)
    end
  end

end
