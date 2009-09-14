module GitDB::Commands

  def self.commands
    @commands
  end

  def self.execute(command, args=[])
    return unless commands
    raise ArgumentError, "Unknown command: #{command}" unless commands[command]
    commands[command].execute(args)
  end

  def self.register(command, klass)
    @commands ||= {}
    @commands[command] = klass.new
  end

end

require 'git-db/commands/receive-pack'
require 'git-db/commands/upload-pack'
