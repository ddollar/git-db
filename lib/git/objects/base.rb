class GitDB::Git::Objects::Base

  attr_reader :data

  def initialize(data)
    @data = data
  end

  def inspect
    %{#<#{self.class} #{inspect_arguments_as_string}>}
  end

  def sha
    Digest::SHA1.hexdigest(raw)
  end

private ######################################################################

  def inspect_arguments
    [:data]
  end

  def inspect_arguments_as_string
    inspect_arguments.unshift(:sha).map do |argument|
      "#{argument}=#{self.send(argument).inspect}"
    end.join(' ')
  end

end
