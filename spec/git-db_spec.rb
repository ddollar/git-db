require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "GitDB" do

  describe "git utility" do
    it "can convert shas to/from hex/binary representation" do
      @hex = "6161616161616161616161616161616161616161"
      @sha = "aaaaaaaaaaaaaaaaaaaa"

      GitDB.hex_to_sha1(@hex.dup).should == @sha.dup
      GitDB.sha1_to_hex(@sha.dup).should == @hex.dup
    end

    it "has a null sha" do
      GitDB.null_sha1.should == "0000000000000000000000000000000000000000"
    end
  end

  describe "logging" do
    it "has a logger that can respond to puts" do
      GitDB.logger.should respond_to(:puts)
    end

    describe "with DEBUG" do
      before(:each) do
        ENV["DEBUG"] = "1"
      end

      it "logs messages sent to log" do
        @logger  = mock(Logger)
        @message = "Log This"

        GitDB.should_receive(:logger).and_return(@logger)
        @logger.should_receive(:puts).with(@message)

        GitDB.log(@message)
      end
    end

    describe "without DEBUG" do
      before(:each) do
        ENV["DEBUG"] = nil
      end

      it "should not log messages sent to log" do
        @logger  = mock(Logger)
        @message = "Log This"

        GitDB.should_not_receive(:logger)

        GitDB.log(@message)
      end
    end
  end

  describe "database" do
    it "returns a database for a repository" do
      @repository = "Test Repository"

      GitDB::Database.should_receive(:database).with(@repository)

      GitDB.database(@repository)
    end
  end

end
