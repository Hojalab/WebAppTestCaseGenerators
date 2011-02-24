class Transition
  attr_reader :source, :sink, :code

  def initialize(src, snk, c)
    if src.nil? || !src.is_a?(String) || src.blank?
      raise ArgumentError, "Given source of transition cannot be blank or nil, and must be a String (got #{src.class.name})"
    end
    @source = src
    if snk.nil? || !snk.is_a?(RailsURL)
      raise ArgumentError, "Given sink of transition cannot be nil, and must be a RailsURL (got #{snk.class.name})"
    end
    @sink = snk
    if c.nil? || !c.is_a?(String) || c.blank?
      raise ArgumentError, "Given transition code cannot be blank or nil, and must be a String (got #{c.class.name})"
    end
    @code = c
  end

  def inspect
    to_s
  end

  def to_s(prefix='')
    sprintf("\t%s<%s> --> <%s>\n%s\tUnderlying code: %s", prefix, @source, @sink, prefix, @code)
  end
end
