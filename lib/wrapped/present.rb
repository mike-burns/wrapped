# A class that represents a wrapped value. This class holds something that is
# not nil.
class Present
  include Enumerable

  # Use Object#wrapped and NilClass#wrapped instead.
  def initialize(value) # :nodoc:
    @value = value
  end

  # Produce the value, unwrapped.
  #
  # If a block is given apply the block to the value and produce that.
  #
  # > w.unwrap_or(0)
  # > w.unwrap_or("hello") {|s| "Hi, #{s}" }
  def unwrap_or(_)
    if block_given?
      yield unwrap
    else
      unwrap
    end
  end

  # Invoke the block on the value, unwrapped. This method produces the wrapped
  # value again, making it chainable. See `blank' for its companion.
  #
  # > w.present {|s| puts "Hello, #{s}" }.blank { puts "Do I know you?" }
  def present(&block)
    block.call(unwrap)
    self
  end

  # Do nothing then produce the wrapped value, making it chainable. See
  # `present' for its companion.
  #
  # > w.blank { puts "Symbol not found" }.present {|s| puts users[s]}
  def blank(&ignored)
    self
  end

  # Produce the singleton list with the unwrapped value as its only member.
  #
  # If a block is passed, it is run against the unwrapped value.
  #
  # This class mixes in Enumerable, which is controlled by this method.
  #
  # > w.each {|n| puts "Found #{n}" }
  def each
    yield unwrap if block_given?
    [unwrap]
  end

  # The raw value. I doubt you need this method.
  def unwrap
    @value
  end

  # True; this is an instance of a wrapped value.
  def present?
    true
  end

  # False; this does not wrap a nil.
  def blank?
    false
  end

  # Run a block against the unwrapped value, producing the result of the block.
  #
  # > w.try {|n| n+1 }
  #
  # Also, you can use this like you would use >>= in Haskell. This and wrapped
  # make it a monad.
  #
  # > w.try {|n| (n+1).wrapped }
  def try
    yield unwrap
  end

  # Run a block within the wrapper. This produces a wrapped value.
  #
  # > w.try {|n| n+1 }
  #
  # This makes it a functor.
  def fmap
    (yield unwrap).wrapped
  end
end
