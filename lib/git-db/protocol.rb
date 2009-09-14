class GitDB::Protocol

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
    # length is stored in the first 4 bytes
    length = reader.read(4)
    return nil unless length

    # length is stored as hex, convert back to decimal and return if it's 0
    length = length.to_i(16)
    return if length.zero?

    # length includes the 4 bytes of the length itself, subtract for data
    length -= 4

    # read and return the data
    data = reader.read(length)
    GitDB.log("RECEIVED COMMAND: #{data.inspect}")
    data
  end

  def write_command(command)
    # output the length
    writer.print length_as_hex(command)

    # output the data
    GitDB.log("SENDING COMMAND: #{command.inspect}")
    writer.print command
    writer.flush
  end

  def write(data)
    writer.write data
    writer.flush
  end

  def write_eof
    writer.print '0000'
    writer.flush
  end

## packs #####################################################################

  def read_pack
    GitDB::Pack.new(reader).read
  end

  def write_pack(entries)
    GitDB::Pack.new(writer).write(entries)
  end

private ######################################################################

  def length_as_hex(command)
    hex = (command.length + 4).to_s(16).rjust(4, '0')
  end

end
