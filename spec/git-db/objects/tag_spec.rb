require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "GitDB::Objects::Tag" do

  before(:each) do
    # TODO: real tag data
    @data = "test-tag"
    @tag  = GitDB::Objects::Tag.new(@data)
  end

  it "has a type" do
    @tag.type.should == GitDB::OBJ_TAG
  end

end
