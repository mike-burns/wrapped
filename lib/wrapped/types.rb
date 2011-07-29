class Present
  include Enumerable

  def initialize(value)
    @value = value
  end

  def unwrap_or(_)
    if block_given?
      yield unwrap
    else
      unwrap
    end
  end

  def present(&block)
    block.call(unwrap)
    self
  end

  def blank(&ignored)
    self
  end

  def each
    yield unwrap if block_given?
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

  def try
    yield unwrap
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
end
