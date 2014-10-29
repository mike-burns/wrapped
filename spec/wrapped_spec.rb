require 'spec_helper'
require 'delegate'

describe Wrapped, 'conversion' do
  let(:value)     { 1 }
  let(:just)      { 1.wrapped }
  let(:nothing)   { nil.wrapped }
  let(:delegator) { SimpleDelegator.new(value).wrapped }

  it "converts the value to a Present" do
    just.should be_instance_of(Present)
  end

  it "converts the nil to a Blank" do
    nothing.should be_instance_of(Blank)
  end

  it "converts a simple delegator to a Present" do
    delegator.should be_instance_of(Present)
    delegator.unwrap.should be_instance_of(SimpleDelegator)
  end
end

describe Wrapped, 'accessing' do
  let(:value)   { 1 }
  let(:just)    { 1.wrapped }
  let(:nothing) { nil.wrapped }

  it 'produces the value of the wrapped object' do
    just.unwrap.should == value
  end

  it 'raises an exception when called on the wrapped nil' do
    expect { nothing.unwrap }.to raise_error(IndexError)
  end
end

describe Wrapped, 'callbacks' do
  let(:value)   { 1 }
  let(:just)    { 1.wrapped }
  let(:nothing) { nil.wrapped }

  it 'calls the proper callback for a wrapped value' do
    result = false
    just.present {|v| result = v}
    result.should be_true
  end

  it 'calls the proper callback for a wrapped nil' do
    result = false
    nothing.blank {result = true}
    result.should be_true
  end

  it 'ignores the other callback for a wrapped value' do
    result = true
    just.blank { result = false }
    result.should be_true
  end


  it 'ignores the other callback for a wrapped nil' do
    result = true
    nothing.present { result = false }
    result.should be_true
  end

  it 'chains for wrapped values' do
    result = false
    just.present { result = true }.blank { result = false }
    result.should be_true
  end

  it 'chains for wrapped nils' do
    result = false
    nothing.present { result = false }.blank { result = true }
    result.should be_true
  end
end

# This behavior is different from Haskell and Scala.
# It is done this way for consistency with Ruby.
# See the functor description later for `fmap'.
describe Wrapped, 'enumerable' do
  let(:value)   { 1 }
  let(:just)    { 1.wrapped }
  let(:nothing) { nil.wrapped }

  it 'acts over the value for #each on a wrapped value' do
    result = -1
    just.each {|v| result = v }
    result.should == value
  end

  it 'produces a singleton array of the value for a wrapped value on #each' do
    just.each.should == [value]
  end

  it 'skips the block for #each on a wrapped nil' do
    result = -1
    nothing.each {|v| result = v }
    result.should == -1
  end

  it 'produces the empty array for a wrapped nil on #each' do
    nothing.each.should be_empty
  end

  it 'maps over the value for a wrapped value' do
    just.map {|n| n + 1}.should == [value+1]
  end

  it 'map produces the empty list for a wrapped nil' do
    nothing.map {|n| n + 1}.should == []
  end
end

describe Wrapped, 'queries' do
  let(:value)   { 1 }
  let(:just)    { 1.wrapped }
  let(:nothing) { nil.wrapped }

  it 'knows whether it is present' do
    just.should be_present
    nothing.should_not be_present
  end

  it 'knows whether it is blank' do
    just.should_not be_blank
    nothing.should be_blank
  end
end

describe Wrapped, 'unwrap_or' do
  let(:value)   { 1 }
  let(:just)    { 1.wrapped }
  let(:nothing) { nil.wrapped }

  it 'produces the value for a wrapped value' do
    just.unwrap_or(-1).should == value
  end

  it 'produces the default for a wrapped nil' do
    nothing.unwrap_or(-1).should == -1
  end

  it 'produces the value of the block for a wrapped object' do
    just.unwrap_or(-1) {|n| n+1}.should == value + 1
  end

  it 'produces the default for a wrapped nil even with a block' do
    nothing.unwrap_or(-1) {2}.should == -1
  end
end

describe Wrapped, 'monadic' do
  let(:value)   { 1 }
  let(:just)    { 1.wrapped }
  let(:nothing) { nil.wrapped }

  it 'produces the value from #flat_map for a wrapped value' do
    just.flat_map {|n| (n+1).wrapped }.unwrap.should == value+1
  end

  it 'produces blank from #flat_map for a wrapped nil' do
    nothing.flat_map {|n| (n+1).wrapped}.should be_blank
  end
end

describe Wrapped, 'functor' do
  let(:value)   { 1 }
  let(:just)    { 1.wrapped }
  let(:nothing) { nil.wrapped }

  it 'unwraps, applies the block, then re-wraps for a wrapped value' do
    just.fmap {|n| n+1}.unwrap.should == value+1
  end

  it 'produces the blank for a wrapped nil' do
    nothing.fmap {|n| n+1}.should be_blank
  end
end

describe Wrapped, 'equality' do
  it 'is equal with the same wrapped value' do
    1.wrapped.should == 1.wrapped
  end

  it 'is not equal with a different wrapped value' do
    1.wrapped.should_not == 2.wrapped
  end

  it 'is equal with two wrapped nils' do
    nil.wrapped.should == nil.wrapped
  end

  it 'is not equal with a wrapped nil and a wrapped value' do
    nil.wrapped.should_not == 1.wrapped
  end

  it 'is not equal with a wrapped value and a wrapped nil' do
    1.wrapped.should_not == nil.wrapped
  end

  it 'is not equal with a present value and un unwrapped value' do
    1.wrapped.should_not == 1
  end

  it 'is not equal with a blank value and an unwrapped value' do
    nil.wrapped.should_not == 1
  end
end
