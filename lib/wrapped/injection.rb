require 'wrapped/present'
require 'wrapped/blank'

class BasicObject
  # Wrap the object, forcing the user to be aware of the potential for a nil
  # value by unwrapping it.
  #
  # See the Present class for details on how to unwrap it.
  def wrapped
    ::Present.new(self)
  end
end

class NilClass
  # Wrap the nil, which is exactly the whole point. At this point the user must
  # explictly deal with the nil, aware that it exists.
  #
  # See the Blank class and the README for details on how to work with this.
  def wrapped
    Blank.new
  end
end
