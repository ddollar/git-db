require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "GitDB::Objects::Base" do

  before(:each) do
    @data = "Test Data"
    @base = GitDB::Objects::Base.new(@data)
  end

  it "initializes with data" do
    @base.data.should == @data
  end

  it "inspects its own properties" do
    @base.should_receive(:properties).and_return([:data])
    @base.inspect
  end

  it "has default properties" do
    @base.properties.should == [:data]
  end

  it "has default raw" do
    @base.raw.should == @data
  end

end
