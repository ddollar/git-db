require 'logger'

module GitDB;

  def self.logger
    @logger ||= File.open("/tmp/git-db.log", "w")
    #@logger ||= STDERR
  end

  def self.log(message)
    logger.puts message
  end
end

require 'git'
require 'utility'
