require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "GitDB::Objects::Blob" do

  before(:each) do
    @data   = "test blob"
    @blob = GitDB::Objects::Blob.new(@data)
  end

  it "has a raw value" do
    @blob.raw.should == "blob #{@data.length}\000#{@data}"
  end

  it "has a type" do
    @blob.type.should == GitDB::OBJ_BLOB
  end

end
