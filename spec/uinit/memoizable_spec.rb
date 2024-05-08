# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Style/StringConcatenation
class BaseMemoizableTest
  def self.memoized_static_method
    'base'
  end

  def memoized_instance_method
    'base'
  end
end

class MemoizableTest < BaseMemoizableTest
  include Uinit::Memoizable

  memo_self def self.memoized_static_method
    super + " memoized static_method ref #{@ref}"
  end

  def self.reference=(value)
    @ref = value
  end

  memo def memoized_instance_method
    super + " memoized instance_method ref #{@ref}"
  end

  def reference=(value)
    @ref = value
  end
end

class InheritedMemoizableTest < MemoizableTest
  memo_self def self.memoized_static_method
    'inherited ' + super
  end

  def self.reference=(value)
    @ref = value
  end

  memo def memoized_instance_method
    # binding.pry
    # raise
    'inherited ' + super
  end

  def reference=(value)
    @ref = value
  end
end
# rubocop:enable Style/StringConcatenation

RSpec.describe Uinit::Memoizable do
  before do
    MemoizableTest.memo_unset(:memoized_static_method)
    InheritedMemoizableTest.memo_unset(:memoized_static_method)
  end

  it 'works for instance method' do
    object = MemoizableTest.new

    object.reference = 'ok'
    expect(object.memoized_instance_method).to eq('base memoized instance_method ref ok')

    object.reference = 'oups'
    expect(object.memoized_instance_method).to eq('base memoized instance_method ref ok')

    object.memo_unset(:memoized_instance_method)
    expect(object.memoized_instance_method).to eq('base memoized instance_method ref oups')
  end

  it 'works for with super on instance' do
    object = InheritedMemoizableTest.new

    object.reference = 'ok'
    expect(object.memoized_instance_method).to eq('inherited base memoized instance_method ref ok')

    object.reference = 'oups'
    expect(object.memoized_instance_method).to eq('inherited base memoized instance_method ref ok')

    object.memo_unset(:memoized_instance_method)
    expect(object.memoized_instance_method).to eq('inherited base memoized instance_method ref oups')
  end

  it 'works for static method' do
    MemoizableTest.reference = 'ok'
    expect(MemoizableTest.memoized_static_method).to eq('base memoized static_method ref ok')

    MemoizableTest.reference = 'oups'
    expect(MemoizableTest.memoized_static_method).to eq('base memoized static_method ref ok')

    MemoizableTest.memo_unset(:memoized_static_method)
    expect(MemoizableTest.memoized_static_method).to eq('base memoized static_method ref oups')
  end

  it 'works for with super on static' do
    InheritedMemoizableTest.reference = 'ok'
    expect(InheritedMemoizableTest.memoized_static_method).to eq('inherited base memoized static_method ref ok')

    InheritedMemoizableTest.reference = 'oups'
    expect(InheritedMemoizableTest.memoized_static_method).to eq('inherited base memoized static_method ref ok')

    InheritedMemoizableTest.memo_unset(:memoized_static_method)
    expect(InheritedMemoizableTest.memoized_static_method).to eq('inherited base memoized static_method ref oups')
  end
end
