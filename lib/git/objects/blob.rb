class GitDB::Git::Objects::Blob < GitDB::Git::Objects::Base

  def raw
    "blob #{data.length}\000#{data}"
  end

  def type
    Git::OBJ_BLOB
  end

end
