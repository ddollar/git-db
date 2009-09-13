require 'fileutils'
require 'zlib'

class GitDB::Git::Commands::ReceivePack

  def execute(args)
    repository = args.first
    raise ArgumentError, "repository required" unless repository

    needs_capabilities = true
    each_git_ref do |ref, sha|
      #write_ref(ref, sha, needs_capabilities)
      #needs_capabilities = false
    end
    write_ref("capabilities^{}", null_sha1) if needs_capabilities
    io.write_eof
    
    refs = []
    new_shas = []
    
    while (data = io.read_command)
      old_sha, new_sha, ref = data.split(' ')
      ref, report = ref.split(0.chr)
      refs << ref
      new_shas << new_sha
      if new_sha == null_sha1
        delete_git_file(ref)
      else
        write_git_file(ref, new_sha)
      end
      # GitDB.log("OLDSHA: #{old_sha}")
      # GitDB.log("NEWSHA: #{new_sha}")
      # GitDB.log("REF: #{ref}")
      # GitDB.log("REPORT: #{report}")
    end
    
    unless new_shas.reject { |sha| sha == null_sha1 }.length.zero?
      while (entries = io.read_pack)
        entries.each do |entry|
          filename = "objects/#{entry.sha[0..1]}/#{entry.sha[2..-1]}"
          write_git_file(filename, Zlib::Deflate.deflate(entry.raw))
        end
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
    if needs_capabilities
      header = "%s %s\000%s\n" % [ sha, ref, capabilities ]
      io.write_command(header)
    else
      header = "%s %s\n" % [ sha, ref ]
    end
  end

end

GitDB::Git::Commands.register 'receive-pack', GitDB::Git::Commands::ReceivePack
