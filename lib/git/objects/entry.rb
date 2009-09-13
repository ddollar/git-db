require 'stringio'

class GitDB::Git::Objects::Entry < GitDB::Git::Objects::Base

  attr_reader :sha, :permissions, :name

  def initialize(sha, permissions, name)
    @sha = sha
    @permissions = permissions
    @name = name
  end

private ######################################################################

  def inspect_arguments
    [:permissions, :name]
  end

end
