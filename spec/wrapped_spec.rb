require 'spec_helper'
require 'delegate'

describe Wrapped, 'conversion' do
  let(:value)     { 1 }
  let(:just)      { 1.wrapped }
  let(:nothing)   { nil.wrapped }
  let(:delegator) { SimpleDelegator.new(value).wrapped }

  it "converts the value to a Present" do
    expect(just).to be_instance_of(Present)
  end

  it "converts the nil to a Blank" do
    expect(nothing).to be_instance_of(Blank)
  end

  it "converts a simple delegator to a Present" do
    expect(delegator).to be_instance_of(Present)
    expect(delegator.unwrap).to be_instance_of(SimpleDelegator)
  end
end

describe Wrapped, 'accessing' do
  let(:value)   { 1 }
  let(:just)    { 1.wrapped }
  let(:nothing) { nil.wrapped }

  it 'produces the value of the wrapped object' do
    expect(just.unwrap).to eq(value)
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
    expect(result).to be_truthy
  end

  it 'calls the proper callback for a wrapped nil' do
    result = false
    nothing.blank {result = true}
    expect(result).to be_truthy
  end

  it 'ignores the other callback for a wrapped value' do
    result = true
    just.blank { result = false }
    expect(result).to be_truthy
  end


  it 'ignores the other callback for a wrapped nil' do
    result = true
    nothing.present { result = false }
    expect(result).to be_truthy
  end

  it 'chains for wrapped values' do
    result = false
    just.present { result = true }.blank { result = false }
    expect(result).to be_truthy
  end

  it 'chains for wrapped nils' do
    result = false
    nothing.present { result = false }.blank { result = true }
    expect(result).to be_truthy
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
    expect(result).to eq(value)
  end

  it 'produces a singleton array of the value for a wrapped value on #each' do
    expect(just.each).to eq([value])
  end

  it 'skips the block for #each on a wrapped nil' do
    result = -1
    nothing.each {|v| result = v }
    expect(result).to eq(-1)
  end

  it 'produces the empty array for a wrapped nil on #each' do
    expect(nothing.each).to be_empty
  end

  it 'maps over the value for a wrapped value' do
    expect(just.map {|n| n + 1}).to eq([value+1])
  end

  it 'map produces the empty list for a wrapped nil' do
    expect(nothing.map {|n| n + 1}).to eq([])
  end
end

describe Wrapped, 'queries' do
  let(:value)   { 1 }
  let(:just)    { 1.wrapped }
  let(:nothing) { nil.wrapped }

  it 'knows whether it is present' do
    expect(just).to be_present
    expect(nothing).not_to be_present
  end

  it 'knows whether it is blank' do
    expect(just).not_to be_blank
    expect(nothing).to be_blank
  end
end

describe Wrapped, 'unwrap_or' do
  let(:value)   { 1 }
  let(:just)    { 1.wrapped }
  let(:nothing) { nil.wrapped }

  it 'produces the value for a wrapped value with an argument' do
    expect(just.unwrap_or(-1)).to eq(value)
  end

  it 'produces the argument for a wrapped nil with an argument' do
    expect(nothing.unwrap_or(-1)).to eq(-1)
  end

  it 'produces the value for a wrapped value with a block' do
    expect(just.unwrap_or { value + 1 }).to eq(value)
  end

  it 'produces the block result for a wrapped nil with a block' do
    expect(nothing.unwrap_or { 2 }).to eq(2)
  end
end

describe Wrapped, 'monadic' do
  let(:value)   { 1 }
  let(:just)    { 1.wrapped }
  let(:nothing) { nil.wrapped }

  it 'produces the value from #flat_map for a wrapped value' do
    expect(just.flat_map {|n| (n+1).wrapped }.unwrap).to eq(value+1)
  end

  it 'produces blank from #flat_map for a wrapped nil' do
    expect(nothing.flat_map {|n| (n+1).wrapped}).to be_blank
  end
end

describe Wrapped, 'functor' do
  let(:value)   { 1 }
  let(:just)    { 1.wrapped }
  let(:nothing) { nil.wrapped }

  it 'unwraps, applies the block, then re-wraps for a wrapped value' do
    expect(just.fmap {|n| n+1}.unwrap).to eq(value+1)
  end

  it 'produces the blank for a wrapped nil' do
    expect(nothing.fmap {|n| n+1}).to be_blank
  end

  it 'obeys the functor law: fmap id  ==  id' do
    expect(fmap(id).(just)).to eq(id.(just))
  end

  it 'obeys the functor law: fmap (f . g)  ==  fmap f . fmap g' do
    expect(fmap(compose(null, const(nil))).(just)).
      to eq(compose(fmap(null), fmap(const(nil))).(just))
  end

  def fmap(f)
    lambda { |x| x.fmap(&f) }
  end

  def const(x)
    lambda { |_| x }
  end

  def id
    lambda { |x| x }
  end

  def compose(f, g)
    lambda { |x| f.call(g.call(x)) }
  end

  def null
    lambda {|x| x.nil? }
  end
end

describe Wrapped, 'equality' do
  it 'is equal with the same wrapped value' do
    expect(1.wrapped).to eq(1.wrapped)
  end

  it 'is not equal with a different wrapped value' do
    expect(1.wrapped).not_to eq(2.wrapped)
  end

  it 'is equal with two wrapped nils' do
    expect(nil.wrapped).to eq(nil.wrapped)
  end

  it 'is not equal with a wrapped nil and a wrapped value' do
    expect(nil.wrapped).not_to eq(1.wrapped)
  end

  it 'is not equal with a wrapped value and a wrapped nil' do
    expect(1.wrapped).not_to eq(nil.wrapped)
  end

  it 'is not equal with a present value and un unwrapped value' do
    expect(1.wrapped).not_to eq(1)
  end

  it 'is not equal with a blank value and an unwrapped value' do
    expect(nil.wrapped).not_to eq(1)
  end
end
