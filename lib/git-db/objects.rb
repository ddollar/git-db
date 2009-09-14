module GitDB::Objects; 

  def self.new_from_type(type, data)
    case type
      when GitDB::OBJ_COMMIT then GitDB::Objects::Commit.new(data)
      when GitDB::OBJ_TREE   then GitDB::Objects::Tree.new(data)
      when GitDB::OBJ_BLOB   then GitDB::Objects::Blob.new(data)
      when GitDB::OBJ_TAG    then GitDB::Objects::Tag.new(data)
      else raise "Unknown object type: #{type}"
    end
  end

end

require 'git-db/objects/base'
require 'git-db/objects/blob'
require 'git-db/objects/commit'
require 'git-db/objects/entry'
require 'git-db/objects/tag'
require 'git-db/objects/tree'
