require 'stringio'

class GitDB::Git::Objects::Tree < GitDB::Git::Objects::Base

  def entries
    @entries ||= begin
      entries = []
      stream = StringIO.new(data)
      until stream.eof?
        perms = read_until(stream, ' ').to_i
        name  = read_until(stream, 0.chr)
        sha   = Git.sha1_to_hex(stream.read(20))
        entries << GitDB::Git::Objects::Entry.new(sha, perms, name)
      end
      entries
    end
  end

  def raw
    "tree #{data.length}\000#{data}"
  end

  def type
    Git::OBJ_TREE
  end

private ######################################################################

  def inspect_arguments
    [:entries]
  end

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
