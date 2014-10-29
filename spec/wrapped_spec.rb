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

describe Wrapped, 'enumerable' do
  let(:value)   { 1 }
  let(:just)    { 1.wrapped }
  let(:nothing) { nil.wrapped }

  it 'acts over the value for #each on a wrapped value' do
    result = -1
    just.each {|v| result = v }
  end

  it 'produces itself for #each' do
    expect(just.each).to eq(just)
  end

  it 'skips the block for #each on a wrapped nil' do
    result = -1
    nothing.each {|v| result = v }
    expect(result).to eq(-1)
  end

  it 'produces blank for a wrapped nil on #each' do
    expect(nothing.each).to eq(nothing)
  end

  it 'maps over the value for a wrapped value' do
    expect(just.map {|n| n + 1}).to eq((value+1).wrapped)
  end

  it 'map produces blank' do
    expect(nothing.map {|n| n + 1}).to be_instance_of(Blank)
  end

  it 'aliases map to collect' do
    expect(just.method(:collect)).to be_alias_of(just.method(:map))
    expect(nothing.method(:collect)).to be_alias_of(nothing.method(:map))
  end

  it 'select produces present for a value matching the block' do
    expect(just.select { |n| n == value }).to eq(just)
  end

  it 'select produces blank for a value that does not match the block' do
    expect(just.select { |n| n != value }).to be_instance_of(Blank)
  end

  it 'select products blank for a blank' do
    expect(nothing.select { true }).to be_instance_of(Blank)
  end

  it 'aliases select to find_all' do
    expect(just.method(:find_all)).to be_alias_of(just.method(:select))
    expect(nothing.method(:find_all)).to be_alias_of(nothing.method(:select))
  end

  it 'reject produces present for a value matching the block' do
    expect(just.reject { |n| n != value }).to eq(just)
  end

  it 'reject produces blank for a value that does not match the block' do
    expect(just.reject { |n| n == value }).to be_instance_of(Blank)
  end

  it 'reject products blank for a blank' do
    expect(nothing.reject { true }).to be_instance_of(Blank)
  end

  it 'grep produces present for a value matching the pattern' do
    expect("hello".wrapped.grep(/ello$/)).to eq("hello".wrapped)
  end

  it 'grep produces blank for a value that does not match the pattern' do
    expect("hello".wrapped.grep(/^ello/)).to be_instance_of(Blank)
  end

  it 'grep products blank for a blank' do
    expect(nothing.grep(/.*/)).to be_instance_of(Blank)
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

  it 'produces the value for a wrapped value' do
    expect(just.unwrap_or(-1)).to eq(value)
  end

  it 'produces the default for a wrapped nil' do
    expect(nothing.unwrap_or(-1)).to eq(-1)
  end

  it 'produces the value of the block for a wrapped object' do
    expect(just.unwrap_or(-1) {|n| n+1}).to eq(value + 1)
  end

  it 'produces the default for a wrapped nil even with a block' do
    expect(nothing.unwrap_or(-1) {2}).to eq(-1)
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
end
