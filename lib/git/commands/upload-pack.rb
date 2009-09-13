require 'fileutils'
require 'zlib'

class GitDB::Git::Commands::UploadPack

  def execute(args)
    repository = args.first
    raise ArgumentError, "repository required" unless repository

    each_git_ref do |ref, sha|
      #write_ref(ref, sha)
      write_ref(ref, sha.gsub('9', '1'))
    end
    io.write_eof

    shas = []

    while (data = io.read_command)
      command, sha, options = data.split(' ', 3)
      GitDB.log("COMMAND: #{command}")
      GitDB.log("SHA: #{sha}")
      GitDB.log("OPTIONS: #{options}")
      shas << sha
      # old_sha, new_sha, ref = data.split(' ')
      # ref, report = ref.split(0.chr)
      # refs << ref
      # new_shas << new_sha
      # if new_sha == null_sha1
      #   delete_git_file(ref)
      # else
      #   write_git_file(ref, new_sha)
      # end
    end

    io.write_command "NAK"    
    shas.each do |sha|
      io.write_command("shallow #{sha}")
    end
    
    while (data = io.read_command)
      command, sha, options = data.split(' ', 3)
      # GitDB.log("COMMAND: #{command}")
      # GitDB.log("SHA: #{sha}")
      # GitDB.log("OPTIONS: #{options}")
      if command == 'done'
        io.write_command "NAK"
      else
        io.write_command "ACK #{sha}"
      end
    end
    io.flush

  end

private

  def capabilities
    " thin-pack shallow include-tag"
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

  def delete_git_file(filename)
    filename = "/tmp/foo/.git/#{filename}"
    GitDB.log("REMOVING: #{filename}")
    FileUtils.rm_rf(filename)
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
