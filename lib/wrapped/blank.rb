class Blank
  include Enumerable

  def unwrap
    raise IndexError.new("Blank has no value")
  end

  def unwrap_or(default)
    default
  end

  def present
    self
  end

  def blank(&block)
    block.call
    self
  end

  def each
    []
  end

  def present?
    false
  end

  def blank?
    true
  end

  def try
    self
  end

  def fmap
    self
  end
end
