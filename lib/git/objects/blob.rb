class GitDB::Git::Objects::Blob < GitDB::Git::Objects::Base

  def raw
    "blob #{data.length}\000#{data}"
  end

end
