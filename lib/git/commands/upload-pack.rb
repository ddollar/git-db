require 'fileutils'
require 'zlib'

class GitDB::Git::Commands::UploadPack

  def execute(args)
    repository = args.first
    raise ArgumentError, "repository required" unless repository

    each_git_ref do |ref, sha|
      write_ref(ref, sha)
      #write_ref(ref, sha.gsub('9', '1'))
    end
    io.write_eof

    shas = []

    while (data = io.read_command)
      command, sha, options = data.split(' ', 3)
      # GitDB.log("COMMAND: #{command}")
      # GitDB.log("SHA: #{sha}")
      # GitDB.log("OPTIONS: #{options}")
      shas << sha
    end

    io.write_command "NAK\n"    

    shas.each do |sha|
      #io.write_command("ACK #{sha}\n")
      data = read_git_object(sha)
      entry = case data.split(' ', 2).first
        when 'commit' then GitDB::Git::Objects::Commit.new(data)
      end
      io.write_pack([entry])
    end

    while (data = io.read_command)
      command, sha, options = data.split(' ', 3)
      GitDB.log("COMMAND: #{command}")
      GitDB.log("SHA: #{sha}")
      GitDB.log("OPTIONS: #{options}")
      shas << sha
    end
    
    # while (data = io.read_command)
    #   command, sha, options = data.split(' ', 3)
    #   # GitDB.log("COMMAND: #{command}")
    #   # GitDB.log("SHA: #{sha}")
    #   # GitDB.log("OPTIONS: #{options}")
    #   if command == 'done'
    #     io.write_command "NAK\n"
    #     break
    #   else
    #     io.write_command "ACK #{sha}\n"
    #   end
    # end

    # entries = shas.map do |sha|
    #   data = read_git_object(sha)
    #   case data.split(' ', 2).first
    #     when 'commit' then GitDB::Git::Objects::Commit.new(data)
    #   end
    # end
    # 
    # #GitDB.log(entries.map { |e| e.inspect })
    # 
    # io.write_pack(entries)
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
