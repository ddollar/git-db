class GitDB::Git::Objects::Tag < GitDB::Git::Objects::Base

  def type
    Git::OBJ_TAG
  end

end
