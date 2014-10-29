# The class represents a lack of something.
class Blank
  include Enumerable

  # It is an error (specifically, an IndexError) to use this method.
  def unwrap
    raise IndexError.new("Blank has no value")
  end

  # Produce the value that is passed in.
  #
  # > w.unwrap_or(0)
  def unwrap_or(default)
    default
  end

  # Does nothing, returning itself. This is chainable. See blank for its
  # companion.
  #
  # w.present.blank { puts "Missing" }
  def present
    self
  end

  # Call the block then return itself. This is chainable. See present for its
  # companion.
  #
  # w.blank { puts "I got nothing" }.present {|n| puts "got #{n}" }
  def blank(&block)
    block.call
    self
  end

  # Produce the empty list.
  #
  # This class mixes in the Enumerable module, which relies on this.
  #
  # > w.each {|n| puts n }
  def each
    self
  end

  # Produces itself.
  def select
    self
  end

  alias_method :find_all, :select

  # Produces itself.
  def reject
    self
  end

  # Produces itself.
  def grep(*_args)
    self
  end

  # False; this is not an instance of a wrapped value.
  def present?
    false
  end

  # True; this is an instance of nothing.
  def blank?
    true
  end

  # Do nothing, returning itself.
  #
  # > w.flat_map {|n| n+1 }
  def flat_map
    self
  end

  # Do nothing, returning itself.
  #
  # > w.fmap {|n| n+1 }
  def fmap
    self
  end

  alias_method :collect, :fmap
  alias_method :map, :fmap

  # Is this wrapped value equal to the given wrapped value? All blank values
  # are equal to each other.
  #
  # > nil.wrapped == nil.wrapped
  # > 1.wrapped == nil.wrapped
  def ==(other)
    other.blank?
  end
end
