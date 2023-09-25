require 'spec_helper'
require 'ghostest/attr_reader'

RSpec.describe AttrReader do
  class DummyClass
    include AttrReader
    attr_reader :var1, :var2

    def initialize
      @var1 = 'value1'
      @var2 = 'value2'
    end
  end

  let(:dummy_class) { DummyClass.new }

  it 'defines methods for instance variables' do
    expect(dummy_class.var1).to eq 'value1'
    expect(dummy_class.var2).to eq 'value2'
  end

  context 'when no arguments are passed to attr_reader' do
    class NoArgsClass
      include AttrReader
      attr_reader
    end

    let(:no_args_class) { NoArgsClass.new }

    it 'does not raise an error and does not define any methods' do
      expect { no_args_class.random_method }.to raise_error(NoMethodError)
    end
  end

  context 'when the instance variable does not exist' do
    class NonExistentVarClass
      include AttrReader
      attr_reader :non_existent_var
    end

    let(:non_existent_var_class) { NonExistentVarClass.new }

    it 'defines the method and returns nil when called' do
      expect(non_existent_var_class.non_existent_var).to be_nil
    end
  end

  context 'when one argument is passed to attr_reader' do
    class OneArgClass
      include AttrReader
      attr_reader :var

      def initialize
        @var = 'value'
      end
    end

    let(:one_arg_class) { OneArgClass.new }

    it 'defines method for the instance variable' do
      expect(one_arg_class.var).to eq 'value'
    end
  end

  context 'when multiple arguments are passed to attr_reader' do
    class MultipleArgsClass
      include AttrReader
      attr_reader :var1, :var2, :var3

      def initialize
        @var1 = 'value1'
        @var2 = 'value2'
        @var3 = 'value3'
      end
    end

    let(:multiple_args_class) { MultipleArgsClass.new }

    it 'defines methods for all instance variables' do
      expect(multiple_args_class.var1).to eq 'value1'
      expect(multiple_args_class.var2).to eq 'value2'
      expect(multiple_args_class.var3).to eq 'value3'
    end
  end
end
