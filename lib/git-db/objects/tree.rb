require 'stringio'

class GitDB::Objects::Tree < GitDB::Objects::Base

  # TODO: memoize entries

  def entries
    entries = []
    stream = StringIO.new(data)
    until stream.eof?
      perms = read_until(stream, ' ').to_i
      name  = read_until(stream, 0.chr)
      sha   = GitDB.sha1_to_hex(stream.read(20))
      entries << GitDB::Objects::Entry.new(sha, perms, name)
    end
    entries
  end

  def properties
    [:entries]
  end

  def raw
    "tree #{data.length}\000#{data}"
  end

  def type
    GitDB::OBJ_TREE
  end

private ######################################################################

  def read_until(stream, separator)
    data = ""
    char = ""
    loop do
      char = stream.read(1)
      break if char.nil?
      break if char == separator
      data << char
    end
    data
  end

end
