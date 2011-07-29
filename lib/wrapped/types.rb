class Present
  include Enumerable

  def initialize(value)
    @value = value
  end

  def unwrap_or(_)
    unwrap
  end

  def present(&block)
    block.call(unwrap)
    self
  end

  def blank(&ignored)
    self
  end

  def each(&block)
    block.call(unwrap) unless block.nil?
    [unwrap]
  end

  def unwrap
    @value
  end

  def present?
    true
  end

  def blank?
    false
  end
end

class Blank
  include Enumerable

  def unwrap
    raise IndexError.new("Blank has no value")
  end

  def unwrap_or(default)
    default
  end

  def present(&ignored)
    self
  end

  def blank(&block)
    block.call
    self
  end

  def each(&ignored)
    []
  end

  def present?
    false
  end

  def blank?
    true
  end
end
