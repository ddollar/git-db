require 'base64'
require 'couchrest'
require 'logger'

module GitDB;

## git constants #############################################################

  OBJ_NONE      = 0
  OBJ_COMMIT    = 1
  OBJ_TREE      = 2
  OBJ_BLOB      = 3
  OBJ_TAG       = 4
  OBJ_OFS_DELTA = 6
  OBJ_REF_DELTA = 7
  
## git utility ###############################################################

  def self.sha1_to_hex(sha)
    hex = ""
    sha.split('').each do |char|
      val = char[0]
      hex << (val >>  4).to_s(16)
      hex << (val & 0xf).to_s(16)
    end
    hex
  end

  def self.hex_to_sha1(hex)
    sha = ""
    len = 0
    until (len == hex.length)
      val = (hex[len,   1].to_i(16) << 4)
      val += hex[len+1, 1].to_i(16)
      sha << val.chr
      len += 2
    end
    sha
  end

  def self.null_sha1
    "0000000000000000000000000000000000000000"
  end

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

require 'git-db/commands'
require 'git-db/database'
require 'git-db/objects'
require 'git-db/pack'
require 'git-db/protocol'
require 'git-db/utility'
