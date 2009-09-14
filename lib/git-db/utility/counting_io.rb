class GitDB::Utility::CountingIO

  attr_reader :io, :offset

  def initialize(io)
    @io = io
    @offset = 0
  end

  def flush
    io.flush
  end

  def read(n)
    data = io.read(n)
    @offset += n
    data
  end

  def write(data)
    io.write(data)
  end

end
