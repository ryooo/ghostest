require 'spec_helper'

RSpec.describe Llm::Functions::RecordLgtm do
  let(:record_lgtm) { Llm::Functions::RecordLgtm.new }

  describe '#function_name' do
    it 'returns :record_lgtm' do
      expect(record_lgtm.function_name).to eq :record_lgtm
    end
  end

  describe '#initialize' do
    it 'sets @lgtm to false' do
      expect(record_lgtm.instance_variable_get(:@lgtm)).to eq false
    end
  end

  describe '#stop_llm_call?' do
    it 'returns true' do
      expect(record_lgtm.stop_llm_call?).to eq true
    end
  end

  describe '#lgtm?' do
    it 'returns the boolean value of @lgtm' do
      expect(record_lgtm.lgtm?).to eq false
    end
  end

  describe '#definition' do
    it 'returns the correct function definition' do
      expected_definition = {
        name: :record_lgtm,
        description: I18n.t('functions.record_lgtm.description'),
        parameters: {
          type: :object,
          properties: {
            message: {
              type: :string,
              description: I18n.t('functions.record_lgtm.parameters.message'),
            },
          },
          required: [:message],
        },
      }
      expect(record_lgtm.definition).to eq expected_definition
    end
  end

  describe '#execute_and_generate_message' do
    it 'sets @lgtm to true and returns a message' do
      args = { message: 'Test message' }
      expect(record_lgtm.execute_and_generate_message(args)).to eq args
      expect(record_lgtm.instance_variable_get(:@lgtm)).to eq true
    end
  end
end
