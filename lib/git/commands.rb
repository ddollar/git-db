module GitDB::Git::Commands

  def self.execute(command, args=[])
    return unless @commands
    raise ArgumentError, "Unknown command: #{command}" unless @commands[command]
    @commands[command].execute(args)
  end

  def self.register(command, klass)
    @commands ||= {}
    @commands[command] = klass.new
  end

end

require 'git/commands/receive-pack'