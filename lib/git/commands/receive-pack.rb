require 'fileutils'
require 'zlib'

class GitDB::Git::Commands::ReceivePack

  def execute(args)
    repository = args.first
    raise ArgumentError, "repository required" unless repository

    needs_capabilities = true
    GitDB.get_refs(repository).each do |ref, sha|
      GitDB.log("ISAERF #{ref} #{sha}")
      write_ref(ref, sha, needs_capabilities)
      needs_capabilities = false
    end
    write_ref("capabilities^{}", Git.null_sha1) if needs_capabilities
    io.write_eof

    refs = []
    new_shas = []

    while (data = io.read_command)
      old_sha, new_sha, ref = data.split(' ')
      ref, report = ref.split(0.chr)

      refs << ref
      new_shas << new_sha

      if new_sha == Git.null_sha1
        GitDB::delete_ref(repository, ref)
      else
        GitDB::write_ref(repository, ref, new_sha)
      end
    end

    unless new_shas.reject { |sha| sha == Git.null_sha1 }.length.zero?
      while (entries = io.read_pack)
        GitDB.write_objects(repository, entries)
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

  def write_ref(ref, sha, needs_capabilities=true)
    if needs_capabilities
      header = "%s %s\000%s\n" % [ sha, ref, capabilities ]
      io.write_command(header)
    else
      header = "%s %s\n" % [ sha, ref ]
      io.write_command(header)
    end
  end

end

GitDB::Git::Commands.register 'receive-pack', GitDB::Git::Commands::ReceivePack
