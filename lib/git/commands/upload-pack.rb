require 'fileutils'
require 'zlib'

class GitDB::Git::Commands::UploadPack

  def execute(args)
    repository = args.first
    raise ArgumentError, "repository required" unless repository

    #execute_transcript(repository)
    execute_real(repository)
  end

  def execute_transcript(repository)
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

    while (data = io.read_command)
      cmd.write_command(data)
      data = data.strip
      break if data == 'done'
      GitDB.log("READ FROM IO #{data}")
    end
    
    while (data = cmd.read_command)
      GitDB.log("GOT COMMAND DATA: #{data.inspect}")
    end

    # data = io.reader.read(9)
    # GitDB.log("READ FROM IO: #{data.inspect}")
    # cmd.writer.write(data)

    # while (data = cmd.read_command)
    #   GitDB.log("CMD COMMAND: #{data.inspect}")
    #   io.write_command(data)
    #   GitDB.log('weee')
    #   if data[0] == 1
    #     GitDB.log("ITS A PACK!")
    #     pack = data[1..-1]
    #     unpacker = GitDB::Git::Pack.new(StringIO.new(pack))
    #     unpacker.read
    #   end
    # end
    # io.write_eof

    # while (data = cmd.read_command)
    #   GitDB.log("CMD COMMAND: #{data}")
    #   io.write_command(data)
    # end
    # io.write_eof
  end

  def execute_real(repository)
    write_ref 'HEAD', GitDB.get_ref(repository, 'refs/heads/master')['sha']

    GitDB.get_refs(repository).each do |ref, sha|
      write_ref(ref, sha)
    end
    io.write_eof

    shas_to_read   = []
    shas_to_ignore = []

    while (data = io.read_command)
      GitDB.log("GOT COMMAND: #{data.inspect}")
      command, sha, options = data.split(' ', 3)
      shas_to_read << sha
    end

    while (data = io.read_command)
      data = data.strip
      break if data == 'done'
      command, sha = data.split(" ", 2)
      case command
        when 'have' then 
          shas_to_ignore << sha
        else
          raise "Unknown SHA command: #{command}"
      end
    end

    if shas_to_ignore.length.zero?
      io.write_command("NAK\n")
    else
      io.write_command("ACK #{shas_to_ignore.last}\n")
    end

    #GitDB.log("TO_IGNORE: #{shas_to_ignore.inspect}")
    shas_to_ignore, _ = load_entries(repository, shas_to_ignore, false)
    # GitDB.log("SHAS_TO_READ: #{shas_to_read.inspect}")
    # GitDB.log("SHAS_READ: #{shas_read.inspect}")

    #GitDB.log("TO_IGNORE: #{shas_to_ignore.inspect}")
    #GitDB.log("TO_READ: #{shas_to_read.inspect}")
    shas, entries = load_entries(repository, shas_to_read, true, shas_to_ignore)

    GitDB.log(entries.map { |e| e.inspect })

    io.write_pack(entries)
  end

private

  def load_entries(repository, shas_to_read, keep_entries, shas_to_ignore=[])
    entries = []
    shas    = []

    while sha = shas_to_read.shift
      next if shas_to_ignore.include?(sha)
      GitDB.log("SHAS_TO_IGNORE: #{shas_to_ignore.sort.inspect}")
      GitDB.log("READING SHA: #{sha}")
      shas_to_ignore << sha

      shas << sha

      object = GitDB.get_object(repository, sha)
      GitDB.log("OBJECT: #{object.inspect}")
      data = object['data']
      type = object['type']

      #GitDB.log("SHADATA: #{data.inspect}")
      case type
        when Git::OBJ_COMMIT then
          commit = GitDB::Git::Objects::Commit.new(data)
          shas_to_read << commit.tree
          shas_to_read += commit.parents if commit.parents
          entries << commit if keep_entries
        when Git::OBJ_TREE then
          tree = GitDB::Git::Objects::Tree.new(data)
          shas_to_read += tree.entries.map { |e| e.sha }
          entries << tree if keep_entries
        when Git::OBJ_BLOB then
          blob = GitDB::Git::Objects::Blob.new(data)
          entries << blob if keep_entries
        else
          raise "UNKNOWN TYPE!! #{type}"
      end
    end

    [shas, entries]
  end

  def capabilities
    " shallow include-tag"
  end

  def io
    @io ||= GitDB::Git::Protocol.new
  end

  def null_sha1
    "0000000000000000000000000000000000000000"
  end

  # def each_git_ref(&block)
  #   Dir["/tmp/foo/.git/refs/*/*"].each do |ref|
  #     sha = File.read(ref).strip
  #     ref = ref.gsub('/tmp/foo/.git/', '')
  #     yield ref, sha
  #   end
  # end

  def head_ref(repository)
    
    # sha = File.read("/tmp/foo/.git/HEAD").strip
    # if sha =~ /ref: (.+)/
    #   sha = File.read("/tmp/foo/.git/#{$1}")
    # end
    # yield "HEAD", sha
  end

  # def delete_git_file(filename)
  #   filename = "/tmp/foo/.git/#{filename}"
  #   GitDB.log("REMOVING: #{filename}")
  #   FileUtils.rm_rf(filename)
  # end

  # def read_git_object(sha)
  #   filename = "/tmp/foo/.git/objects/#{sha[0..1]}/#{sha[2..-1]}"
  #   data = Zlib::Inflate.inflate(File.read(filename))
  # end

  # def write_git_file(filename, data)
  #   filename = "/tmp/foo/.git/#{filename}"
  #   FileUtils.mkdir_p(File.dirname(filename))
  #   File.open(filename, 'w') do |file|
  #     file.print(data)
  #   end
  # end

  def write_ref(ref, sha, needs_capabilities=true)
    header = "%s %s\000%s\n" % [ sha, ref, capabilities ]
    io.write_command(header)
  end

end

GitDB::Git::Commands.register 'upload-pack', GitDB::Git::Commands::UploadPack
