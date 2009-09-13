require 'fileutils'
require 'zlib'

class GitDB::Git::Commands::UploadPack

  def execute(args)
    repository = args.first
    raise ArgumentError, "repository required" unless repository
    
    #execute_transcript
    execute_real
  end

  def execute_transcript
    cmd = GitDB::Git::Protocol.new(IO.popen("/opt/local/bin/git-upload-pack '/tmp/foo'", 'r+'))
    
    while (data = cmd.read_command)
      GitDB.log("CMD COMMAND: #{data}")
      io.write_command(data)
    end
    io.write_eof
    
    while (data = io.read_command)
      GitDB.log("IO COMMAND: #{data}")
      cmd.write_command(data)
    end
    cmd.write_eof
    
    data = io.reader.read(9)
    GitDB.log("READ FROM IO: #{data.inspect}")
    cmd.writer.write(data)
    
    while (data = cmd.read_command)
      GitDB.log("CMD COMMAND: #{data.inspect}")
      io.write_command(data)
      GitDB.log('weee')
      if data[0] == 1
        GitDB.log("ITS A PACK!")
        pack = data[1..-1]
        unpacker = GitDB::Git::Pack.new(StringIO.new(pack))
        unpacker.read
      end
    end
    io.write_eof
    
    while (data = cmd.read_command)
      GitDB.log("CMD COMMAND: #{data}")
      io.write_command(data)
    end
    io.write_eof
  end

  def execute_real
    head_ref do |ref, sha|
      write_ref(ref, sha)
    end
    each_git_ref do |ref, sha|
      write_ref(ref, sha)
      #write_ref(ref, sha.gsub('9', '1'))
    end
    io.write_eof
    
    shas = []
    
    while (data = io.read_command)
      GitDB.log("GOT COMMAND: #{data}")
      command, sha, options = data.split(' ', 3)
      shas << sha
    end
    
    data = io.read_command
    io.write_command("NAK\n")
    
    packer = GitDB::Git::Protocol.new(StringIO.new)
    
    entries = []
    shas_to_read = shas
    shas_read = []

    while shas_to_read.length > 0
      sha = shas_to_read.shift
      next if shas_read.include?(sha)
      shas_read << sha

      raw_data = read_git_object(sha)
      type = raw_data.split(" ").first
      data = raw_data.split("\000", 2).last

      #GitDB.log("SHADATA: #{data.inspect}")
      case type
        when 'commit' then
          commit = GitDB::Git::Objects::Commit.new(data)
          shas_to_read << commit.tree
          shas_to_read += commit.parents if commit.parents
          entries << commit
        when 'tree' then
          tree = GitDB::Git::Objects::Tree.new(data)
          shas_to_read += tree.entries.map { |e| e.sha }
          entries << tree
        when 'blob' then
          blob = GitDB::Git::Objects::Blob.new(data)
          entries << blob
        else
          raise "UNKNOWN!! #{type}"
      end      
    end

    #GitDB.log(entries.map { |e| e.inspect })

    io.write_pack(entries)
  end

private

  def capabilities
    " shallow include-tag"
  end

  def io
    @io ||= GitDB::Git::Protocol.new
  end

  def null_sha1
    "0000000000000000000000000000000000000000"
  end

  def each_git_ref(&block)
    Dir["/tmp/foo/.git/refs/*/*"].each do |ref|
      sha = File.read(ref).strip
      ref = ref.gsub('/tmp/foo/.git/', '')
      yield ref, sha
    end
  end

  def head_ref(&block)
    sha = File.read("/tmp/foo/.git/HEAD").strip
    if sha =~ /ref: (.+)/
      sha = File.read("/tmp/foo/.git/#{$1}")
    end
    yield "HEAD", sha
  end

  def delete_git_file(filename)
    filename = "/tmp/foo/.git/#{filename}"
    GitDB.log("REMOVING: #{filename}")
    FileUtils.rm_rf(filename)
  end

  def read_git_object(sha)
    filename = "/tmp/foo/.git/objects/#{sha[0..1]}/#{sha[2..-1]}"
    data = Zlib::Inflate.inflate(File.read(filename))
  end

  def write_git_file(filename, data)
    filename = "/tmp/foo/.git/#{filename}"
    FileUtils.mkdir_p(File.dirname(filename))
    File.open(filename, 'w') do |file|
      file.print(data)
    end
  end

  def write_ref(ref, sha, needs_capabilities=true)
    header = "%s %s\000%s\n" % [ sha, ref, capabilities ]
    io.write_command(header)
  end

end

GitDB::Git::Commands.register 'upload-pack', GitDB::Git::Commands::UploadPack
