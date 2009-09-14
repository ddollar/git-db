require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "GitDB::Objects::Tree" do

  class TreeEntryFactory
    attr_reader :perms, :name, :sha

    def initialize(perms, name, sha)
      @perms = perms
      @name  = name
      @sha   = sha
    end

    def to_data
      "#{perms} #{name}\000#{GitDB.hex_to_sha1(sha)}"
    end
  end

  before(:each) do
    @entry1 = TreeEntryFactory.new(100644, "entry1", "1111111111111111111111111111111111111111")
    @entry2 = TreeEntryFactory.new(100444, "entry2", "2222222222222222222222222222222222222222")
    @data   = [ @entry1.to_data, @entry2.to_data ].join('')
    @tree   = GitDB::Objects::Tree.new(@data)
  end

  it "has entries" do
    @tree.entries.first.name.should == @entry1.name
    @tree.entries.last.name.should  == @entry2.name
  end

  it "has properties" do
    @tree.properties.should == [:entries]
  end

  it "has a raw value" do
    @tree.raw.should == "tree #{@data.length}\000#{@data}"
  end

  it "has a type" do
    @tree.type.should == GitDB::OBJ_TREE
  end
end
