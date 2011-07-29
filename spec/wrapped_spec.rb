require 'spec_helper'

describe Wrapped, 'conversion' do
  let(:value)   { 1 }
  let(:just)    { 1.wrapped }
  let(:nothing) { nil.wrapped }

  it "converts the value to a Present" do
    just.should be_instance_of(Present)
  end

  it "converts the nil to a Blank" do
    nothing.should be_instance_of(Blank)
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

  it 'produces the value of the block for a wrapped object' do
    just.unwrap {|n| n+1}.should == value+1
  end

  it 'raises an exception when called on the wrapped nil, even with a block' do
    expect { nothing.unwrap { 2 } }.to raise_error(IndexError)
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
