require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "GitDB::Objects" do

  describe "new_from_type" do

    it "can create a commit" do
      GitDB::Objects.new_from_type(GitDB::OBJ_COMMIT, '').should be_a(GitDB::Objects::Commit)
    end

    it "can create a tree" do
      GitDB::Objects.new_from_type(GitDB::OBJ_TREE, '').should be_a(GitDB::Objects::Tree)
    end

    it "can create a blob" do
      GitDB::Objects.new_from_type(GitDB::OBJ_BLOB, '').should be_a(GitDB::Objects::Blob)
    end

    it "can create a tag" do
      GitDB::Objects.new_from_type(GitDB::OBJ_TAG, '').should be_a(GitDB::Objects::Tag)
    end

    it "raises on unknown types" do
      lambda { GitDB::Objects.new_from_type(-1, '') }.should raise_error
    end
  end

end
