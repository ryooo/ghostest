require 'spec_helper'

RSpec.describe Llm::Functions::AddToMemory do
  let(:message_container) { Llm::MessageContainer.new }
  let(:add_to_memory) { Llm::Functions::AddToMemory.new(message_container) }

  describe '#function_name' do
    it 'returns :add_to_memory' do
      expect(add_to_memory.function_name).to eq :add_to_memory
    end
  end

  describe '#definition' do
    it 'returns the correct function definition' do
      expected_definition = {
        name: :add_to_memory,
        description: I18n.t('functions.add_to_memory.description'),
        parameters: {
          type: :object,
          properties: {
            contents_to_memory: {
              type: :string,
              description: I18n.t('functions.add_to_memory.parameters.contents_to_memory'),
            },
          },
          required: [:contents_to_memory],
        },
      }
      expect(add_to_memory.definition).to eq expected_definition
    end
  end

  describe '#execute_and_generate_message' do
    context 'when args hash includes a :contents_to_memory key' do
      it 'adds the correct system message to the message_container' do
        args = { contents_to_memory: 'Test message' }
        add_to_memory.execute_and_generate_message(args)
        expect(message_container.messages).to include({ role: :system, content: I18n.t('functions.add_to_memory.system_message_prefix', contents_to_memory: args[:contents_to_memory]) })
      end

      it 'returns a hash with result: success' do
        args = { contents_to_memory: 'Test message' }
        expect(add_to_memory.execute_and_generate_message(args)).to eq({ result: 'success' })
      end
    end

    context 'when args hash does not include a :contents_to_memory key' do
      it 'raises an error' do
        args = {}
        expect { add_to_memory.execute_and_generate_message(args) }.to raise_error(RuntimeError)
      end
    end

    context 'when args hash includes a :contents_to_memory key but its value is an empty string' do
      it 'raises an error' do
        args = { contents_to_memory: '' }
        expect { add_to_memory.execute_and_generate_message(args) }.to raise_error(RuntimeError)
      end
    end
  end
end
