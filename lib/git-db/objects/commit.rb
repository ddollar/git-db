class GitDB::Objects::Commit < GitDB::Objects::Base

  def author
    attributes['author'].first
  end

  def committer
    attributes['committer'].first
  end

  def message
    data.split("\n\n", 2).last
  end

  def parents
    attributes['parent']
  end

  def properties
    [:tree, :parents, :author, :committer, :message]
  end

  def raw
    "commit #{data.length}\000#{data}"
  end

  def type
    GitDB::OBJ_COMMIT
  end

  def tree
    attributes['tree'].first
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
