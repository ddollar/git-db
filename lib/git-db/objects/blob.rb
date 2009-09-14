class GitDB::Objects::Blob < GitDB::Objects::Base

  def raw
    "blob #{data.length}\000#{data}"
  end

  def type
    GitDB::OBJ_BLOB
  end

end
