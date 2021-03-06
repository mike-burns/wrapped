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
  def unwrap_or(_default = nil)
    unwrap
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

  # Produces itself.
  #
  # If a block is passed, it is run against the unwrapped value.
  #
  # This class mixes in Enumerable, which is controlled by this method.
  #
  # > w.each {|n| puts "Found #{n}" }
  def each
    yield unwrap if block_given?
    self
  end

  # Produces itself if the block evaluates to true. Produces Blank if the block
  # evaluates to false.
  def select
    super.first.wrapped
  end

  alias_method :find_all, :select

  # Produces itself if the block evaluates to false. Produces Blank if the block
  # evaluates to true.
  def reject
    super.first.wrapped
  end

  # Produces itself if the unwrapped value matches the given expression.
  # Produces Blank otherwise.
  def grep(*)
    super.first.wrapped
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
  # > w.flat_map {|n| n+1 }
  #
  # Also, you can use this like you would use >>= in Haskell. This and wrapped
  # make it a monad.
  #
  # > w.flat_map {|n| (n+1).wrapped }
  def flat_map
    yield unwrap
  end

  # Run a block within the wrapper. This produces a wrapped value.
  #
  # > w.fmap {|n| n+1 }
  #
  # This makes it a functor.
  def fmap
    Present.new(yield unwrap)
  end

  alias_method :collect, :fmap
  alias_method :map, :fmap

  # Is this wrapped value equal to the given wrapped value?
  #
  # > 1.wrapped == 1.wrapped
  # > nil.wrapped == 2.wrapped
  def ==(other)
    other.is_a?(Present) && unwrap == other.unwrap_or(nil)
  end
end
