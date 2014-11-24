require 'wrapped'

RSpec::Matchers.define :be_alias_of do |source_method|
  match do |target_method|
    block = lambda { |n| n + 1 }

    target_method.call(&block) == source_method.call(&block)
  end
end
