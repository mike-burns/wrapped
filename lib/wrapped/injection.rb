require 'wrapped/types'

class Object
  def wrapped
    Present.new(self)
  end
end

class NilClass
  def wrapped
    Blank.new
  end
end
