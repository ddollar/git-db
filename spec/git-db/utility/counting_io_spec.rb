require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "GitDB::Utility::CountingIO" do

  before(:each) do
    @base = StringIO.new
    @io   = GitDB::Utility::CountingIO.new(@base)
  end

  it "can flush" do
    @base.should_receive(:flush)
    @io.flush
  end

  it "can read" do
    @data  = "00000"
    @bytes = @data.length

    @base.should_receive(:read).with(@bytes).and_return(@data)
    @io.read(@bytes).should == @data
  end

  it "can write" do
    @data = "00000"

    @base.should_receive(:write).with(@data)
    @io.write(@data)
  end

end
