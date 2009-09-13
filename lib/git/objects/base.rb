class GitDB::Git::Objects::Base

  attr_reader :data

  def initialize(data)
    @data = data
  end

  def inspect
    %{#<#{self.class} #{inspect_properties}>}
  end

  def sha
    Digest::SHA1.hexdigest(raw)
  end

  def properties
    [:data]
  end

private ######################################################################

  def inspect_properties
    properties.unshift(:sha).map do |argument|
      "#{argument}=#{self.send(argument).inspect}"
    end.join(' ')
  end

end
