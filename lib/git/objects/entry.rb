require 'stringio'

class GitDB::Git::Objects::Entry < GitDB::Git::Objects::Base

  attr_reader :sha, :permissions, :data

  def initialize(sha, permissions, data)
    @sha = sha
    @permissions = permissions
    @data = data
  end

private ######################################################################

  def inspect_arguments
    [:permissions, :data]
  end

end
