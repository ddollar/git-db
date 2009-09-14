require 'base64'
require 'couchrest'
require 'logger'

module GitDB;

## logging ###################################################################

  def self.logger
    @logger ||= STDERR
  end

  def self.log(message)
    logger.puts message
  end

## database ##################################################################

  def self.database(repository)
    GitDB::Database.database(repository)
  end
    
end

require 'database'
require 'git'
require 'utility'
