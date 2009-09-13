require 'fileutils'
require 'zlib'

class GitDB::Git::Commands::ReceivePack

  def execute(args)
    repository = args.first
    raise ArgumentError, "repository required" unless repository

    header = "%s %s%c%s\n" % [ null_sha1, "capabilities^{}", 0, capabilities ]
    io.write_command(header)
    io.write_eof
    
    refs = []
    
    while (data = io.read_command)
      old_sha, new_sha, ref = data.split(' ')
      ref, report = ref.split(0.chr)
      refs << ref
      ref_file = "/tmp/foo/.git/#{ref}" 
      write_git_file(ref_file, new_sha)
      # GitDB.log("OLDSHA: #{old_sha}")
      # GitDB.log("NEWSHA: #{new_sha}")
      # GitDB.log("REF: #{ref}")
      # GitDB.log("REPORT: #{report}")
    end
    
    while (entries = io.read_pack)
      entries.each do |entry|
        filename = "/tmp/foo/.git/objects/#{entry.sha[0..1]}/#{entry.sha[2..-1]}"
        write_git_file(filename, Zlib::Deflate.deflate(entry.raw))
      end
    end
    
    io.write_command("unpack ok\n")
    refs.each do |ref|
      io.write_command("ok #{ref}\n")
    end
    io.write_eof
  end

private

  def capabilities
    " report-status delete-refs ofs-delta "
  end

  def io
    @io ||= GitDB::Git::Protocol.new
  end

  def null_sha1
    "0000000000000000000000000000000000000000"
  end

  def write_git_file(filename, data)
    FileUtils.mkdir_p(File.dirname(filename))
    File.open(filename, 'w') do |file|
      file.print(data)
    end
  end

end

GitDB::Git::Commands.register 'receive-pack', GitDB::Git::Commands::ReceivePack
