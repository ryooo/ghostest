require 'spec_helper'

RSpec.describe Llm::Functions::Base do
  let(:base) { Llm::Functions::Base.new }

  describe '#function_name' do
    it 'returns nil' do
      expect(base.function_name).to be_nil
    end
  end

  describe '#stop_llm_call?' do
    it 'returns false' do
      expect(base.stop_llm_call?).to be false
    end
  end
end
