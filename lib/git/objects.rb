module GitDB::Git::Objects; 

  def self.new_from_type(type, data)
    case type
      when Git::OBJ_COMMIT then GitDB::Git::Objects::Commit.new(data)
      when Git::OBJ_TREE   then GitDB::Git::Objects::Tree.new(data)
      when Git::OBJ_BLOB   then GitDB::Git::Objects::Blob.new(data)
      when Git::OBJ_TAG    then GitDB::Git::Objects::Tag.new(data)
      else raise "Unknown object type: #{type}"
    end
  end

end

require 'git/objects/base'
require 'git/objects/blob'
require 'git/objects/commit'
require 'git/objects/entry'
require 'git/objects/tag'
require 'git/objects/tree'
