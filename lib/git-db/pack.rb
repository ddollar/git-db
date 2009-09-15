require 'digest/sha1'
require 'stringio'
require 'zlib'

class GitDB::Pack

  PackObject = Struct.new(:type, :offset, :data)

  attr_reader :io

  def initialize(io)
    @io = GitDB::Utility::CountingIO.new(io)
  end

  def read
    header = io.read(12)
    return nil unless header

    signature, version, entries = header.unpack("a4NN")
    raise 'invalid pack signature' unless signature == 'PACK'
    raise 'invalid version'        unless version   == 2

    objects = {}

    1.upto(entries) do
      object_offset = io.offset
      type, size    = unpack_pack_header(io)

      object = case type
        when 1 then GitDB::Objects::Commit.new(read_compressed(io))
        when 2 then GitDB::Objects::Tree.new(read_compressed(io))
        when 3 then GitDB::Objects::Blob.new(read_compressed(io))
        when 4 then GitDB::Objects::Tag.new(read_compressed(io))
        when 5 then raise 'Invalid Type: 5'
        when 6 then
          # offset delta, find the referred-to pack and apply as a patch
          offset = object_offset - unpack_delta_size(io)
          patch  = read_compressed(io)
          base   = objects[offset]
          data   = apply_patch(base.data, patch)
          base.class.new(data)
        when 7 then
          # TODO: patch against sha
          raise "Type 7 unimplemented, please report"
      end

      objects[object_offset] = object
    end

    # read the checksum, TODO: check the checksum
    checksum = io.read(20)

    objects.values.compact
  end

  def write(entries)
    # build the pack header
    buffer = ["PACK", 2, entries.length].pack("a4NN")

    # deflate the entries
    entries.each do |entry|
      buffer << pack_pack_header(entry.type, entry.data.length)
      buffer << Zlib::Deflate.deflate(entry.data)
    end

    # calculate a checksum
    checksum = GitDB::hex_to_sha1(Digest::SHA1.hexdigest(buffer))

    # write and flush the buffer
    io.write(buffer)
    io.write(checksum)
    io.flush
  end

private ######################################################################

  def apply_patch(original, patch)
    patch_stream     = StringIO.new(patch)
    source_size      = unpack_size(patch_stream)
    destination_size = unpack_size(patch_stream)

    data = ""

    # this pretty much a straight port of the c function in git that does
    # this. it could probably be refactored, but is maintained for
    # symmetry (and to detect potential future changes to git)
    until patch_stream.eof?
      offset = size = 0
      cmd    = patch_stream.read(1)[0]

      if (cmd & 0x80) != 0
        offset  = (patch_stream.read(1)[0])       if (cmd & 0x01).nonzero?
        offset |= (patch_stream.read(1)[0] << 8)  if (cmd & 0x02).nonzero?
        offset |= (patch_stream.read(1)[0] << 16) if (cmd & 0x04).nonzero?
        offset |= (patch_stream.read(1)[0] << 24) if (cmd & 0x08).nonzero?
        size    = (patch_stream.read(1)[0])       if (cmd & 0x10).nonzero?
        size   |= (patch_stream.read(1)[0] << 8)  if (cmd & 0x20).nonzero?
        size   |= (patch_stream.read(1)[0] << 16) if (cmd & 0x40).nonzero?
        size    = 0x10000                         if size.zero?

        if ((offset + size) < size) ||
           ((offset + size) > source_size) ||
           (size > destination_size)
           break
        end
        data += original[offset,size]
      elsif (cmd != 0)
        data += patch_stream.read(cmd)
      end
    end

    data
  end

  def read_compressed(stream)
    zstream = Zlib::Inflate.new
    data = ""
    loop do
      data += zstream.inflate(stream.read(1))
      break if zstream.finished?
    end
    data
  end

  def pack_pack_header(type, size)
    data = ""
    c = (type << 4) | (size & 15);
    size >>= 4;
    while (size > 0)
      data << (c | 0x80).chr
      c = size & 0x7f;
      size >>= 7;
    end
    data << c.chr
  end

  def unpack_delta_size(stream)
    c = stream.read(1)[0]
    size = (c & 127)
    while (c & 128) != 0
      size += 1
      c = stream.read(1)[0]
      size = (size << 7) + (c & 127)
    end
    size
  end

  def unpack_pack_header(stream)
    c = stream.read(1)[0]
    type = (c >> 4) & 7
    size = (c & 15)
    shift = 4
    while ((c & 0x80) != 0)
      c = stream.read(1)[0]
      size += ((c & 0x7f) << shift)
      shift += 7
    end
    [type, size]
  end

  def unpack_size(stream)
    size = shift = 0
    loop do
      c = stream.read(1)[0]
      size += (c & 127) << shift
      shift += 7
      break if (c & 128).zero?
    end
    size
  end

end
