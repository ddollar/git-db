require 'fileutils'
require 'zlib'

class GitDB::Git::Commands::UploadPack

  def execute(args)
    repository = args.first
    raise ArgumentError, "repository required" unless repository

    database = GitDB.database(repository)

    #execute_transcript(database)
    execute_real(database)
  end

  def execute_transcript(database)
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
  end

  def execute_real(database)
    write_ref 'HEAD', database.get_ref('refs/heads/master')['sha']

    database.get_refs.each do |ref, sha|
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

    shas_to_ignore, _ = load_entries(database, shas_to_ignore, false)
    shas, entries     = load_entries(database, shas_to_read, true, shas_to_ignore)

    GitDB.log(entries.map { |e| e.inspect })

    io.write_pack(entries)
  end

private

  def load_entries(database, shas_to_read, keep_entries, shas_to_ignore=[])
    entries = []
    shas    = []

    while sha = shas_to_read.shift
      next if shas_to_ignore.include?(sha)
      GitDB.log("SHAS_TO_IGNORE: #{shas_to_ignore.sort.inspect}")
      GitDB.log("READING SHA: #{sha}")
      shas_to_ignore << sha

      shas << sha

      object = database.get_object(sha)
      GitDB.log("OBJECT: #{object.inspect}")
      data = object.data

      case object
        when GitDB::Git::Objects::Commit then
          commit = GitDB::Git::Objects::Commit.new(data)
          shas_to_read << commit.tree
          shas_to_read += commit.parents if commit.parents
          entries << commit if keep_entries
        when GitDB::Git::Objects::Tree then
          tree = GitDB::Git::Objects::Tree.new(data)
          shas_to_read += tree.entries.map { |e| e.sha }
          entries << tree if keep_entries
        when GitDB::Git::Objects::Blob then
          blob = GitDB::Git::Objects::Blob.new(data)
          entries << blob if keep_entries
        else
          raise "UNKNOWN TYPE!! #{object.class}"
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

  def write_ref(ref, sha, needs_capabilities=true)
    header = "%s %s\000%s\n" % [ sha, ref, capabilities ]
    io.write_command(header)
  end

end

GitDB::Git::Commands.register 'upload-pack', GitDB::Git::Commands::UploadPack
