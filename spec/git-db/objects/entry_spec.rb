require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "GitDB::Objects::Entry" do

  before(:each) do
    @sha   = "1111111111111111111111111111111111111111"
    @perms = 100644
    @name  = "test name"
    @entry = GitDB::Objects::Entry.new(@sha, @perms, @name)
  end

  it "has properties" do
    @entry.properties.should == [:permissions, :name]
  end

  it "converts to a hash" do
    @entry.to_hash[:sha].should         == @sha
    @entry.to_hash[:permissions].should == @perms
    @entry.to_hash[:name].should        == @name
  end

  it "converts to json" do
    @entry.to_json.should == @entry.to_hash.to_json
  end

end
