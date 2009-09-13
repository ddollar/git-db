require 'stringio'

class GitDB::Git::Objects::Entry < GitDB::Git::Objects::Base

  attr_reader :sha, :permissions, :name

  def initialize(sha, permissions, name)
    @sha = sha
    @permissions = permissions
    @name = name
  end

  def properties
    [:permissions, :name]
  end

  def to_json
    { :sha => sha, :permissions => permissions, :name => name }.to_json
  end

private ######################################################################

end
