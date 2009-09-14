require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "GitDB::Objects::Commit" do

  class CommitFactory
    attr_accessor :tree, :parents, :author, :committer, :message

    def to_data
      raw  = ""
      raw << "tree #{tree}\n"
      parents.each do |parent|
        raw << "parent #{parent}\n"
      end
      raw << "author #{author}\n"
      raw << "committer #{committer}\n"
      raw << "\n"
      raw << message
    end
  end

  before(:each) do
    @raw_commit           = CommitFactory.new
    @raw_commit.tree      = "12a3b4d6c8d95475e3faf0e4a7c431c9609057f5"
    @raw_commit.parents   = ["45bef2e266991a468b02a82e7989aca680557f7b"]
    @raw_commit.author    = "David Dollar <ddollar@gmail.com> 1252946959 -0400"
    @raw_commit.committer = "David Dollar <ddollar@gmail.com> 1252946959 -0400"
    @raw_commit.message   = "test message\n"
    @data                 = @raw_commit.to_data

    @commit = GitDB::Objects::Commit.new(@data)
  end

  it "has an author" do
    @commit.author.should == @raw_commit.author
  end

  it "has a committer" do
    @commit.committer.should == @raw_commit.committer
  end

  it "has a message" do
    @commit.message.should == @raw_commit.message
  end

  it "has parents" do
    @commit.parents.should == @raw_commit.parents
  end

  it "has properties" do
    @commit.properties.should == [:tree, :parents, :author, :committer, :message]
  end

  it "has a raw value" do
    @commit.raw.should == "commit #{@data.length}\000#{@data}"
  end

  it "has a tree" do
    @commit.tree.should == @raw_commit.tree
  end

  it "has a type" do
    @commit.type.should == GitDB::OBJ_COMMIT
  end

end
