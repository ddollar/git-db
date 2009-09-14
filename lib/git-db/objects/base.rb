class GitDB::Objects::Base

  attr_reader :data

  def initialize(data)
    @data = data
  end

  def inspect
    %{#<#{self.class} #{inspect_properties}>}
  end

  def properties
    [:data]
  end

  def raw
    data
  end

  def sha
    Digest::SHA1.hexdigest(raw)
  end

private ######################################################################

  def inspect_properties
    inspectors = properties.unshift(:sha).map do |argument|
      "#{argument}=#{self.send(argument).inspect}"
    end
    inspectors.join(' ')
  end

end
