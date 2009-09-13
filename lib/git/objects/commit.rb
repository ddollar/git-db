class GitDB::Git::Objects::Commit < GitDB::Git::Objects::Base
  
  def raw
    "commit #{data.length}\000#{data}"
  end

  def type
    Git::OBJ_COMMIT
  end

  def message
    data.split("\n\n", 2).last
  end

  def author
    attributes['author'].first
  end

  def committer
    attributes['committer'].first
  end

  def tree
    attributes['tree'].first
  end

  def parents
    attributes['parent']
  end

  def properties
    [:tree, :parents, :author, :committer, :message]
  end

private ######################################################################

  def attributes
    @attributes ||= begin
      attributes = data.split("\n\n", 2).first
      attributes.split("\n").inject({}) do |hash, line|
        key, value = line.split(' ', 2)
        hash[key] ||= []
        hash[key]  << value
        hash
      end
    end
  end

end
