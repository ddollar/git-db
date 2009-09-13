class GitDB::Git::Protocol

  attr_reader :reader
  attr_reader :writer

  def initialize(io=nil)
    if io
      @reader = io
      @writer = io
    else
      @reader = STDIN
      @writer = STDOUT
    end
  end

## commands ##################################################################

  def flush
    writer.flush
  end

  def read_command
    length = reader.read(4)
    return nil unless length
    length = length.to_i(16) - 4
    if (length == -4)
      GitDB.log('GOT EOF')
      return
    end
    data = reader.read(length)
    #GitDB.log("GOT DATA: #{data.inspect}")
    data
  end

  def write_command(command)
    raw_command = encode_command(command)
    GitDB.log("WRITING COMMAND: #{raw_command.inspect}")
    writer.print raw_command
    writer.flush
  end

  def write(data)
    writer.write data
    writer.flush
  end

  def write_eof
    #GitDB.log("WRITING EOF")
    writer.print '0000'
    writer.flush
  end

## packs #####################################################################

  def read_pack
    GitDB::Git::Pack.new(reader).read
  end

  def write_pack(entries)
    GitDB::Git::Pack.new(writer).write(entries)
  end

private ######################################################################

  def encode_command(command)
    length_as_hex(command) << command
  end

  def length_as_hex(command)
    hex = (command.length + 4).to_s(16).rjust(4, '0')
  end

end
