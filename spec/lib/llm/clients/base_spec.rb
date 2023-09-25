require 'spec_helper'

RSpec.describe Llm::Clients::Base, type: :client do
  let(:client) {
    mock_client = Llm::Clients::AzureOpenAi.new
    allow(mock_client.client).to receive(:chat).and_return({choices: [{message: { role: :user, content: 'Test user message' }}]})
    mock_client
  }
  let(:agent) { double('Llm::Agents::TestProgrammer', name: 'TestProgrammer', color: :green) }

  before do
    ENV['AZURE_API_VERSION'] = 'v1'
    ENV['AZURE_OPENAI_API_KEY'] = 'dummy key'
    ENV['AZURE_API_BASE'] = 'dummy base'
    ENV['AZURE_DEPLOYMENT_NAME'] = 'dummy deployment name'
  end

  describe '#chat' do
    context 'when the parameters hash does not contain the :messages key or its value is empty' do
      it 'raises an error' do
        expect { client.chat(parameters: {}) }.to raise_error(RuntimeError, 'messages is required.')
        expect { client.chat(parameters: { messages: [] }) }.to raise_error(RuntimeError, 'messages is required.')
      end
    end

    context 'when the parameters hash contains valid data' do
      it 'calls the chat method of the @client object with the given parameters' do
        allow(client).to receive(:chat).and_return(true)
        expect(client.chat(parameters: { messages: ['Hello'] })).to be true
      end
    end
  end

  describe '#chat_with_function_calling_loop' do
    context 'when the :agent key is missing in the arguments' do
      it 'raises an error' do
        expect { client.chat_with_function_calling_loop(messages: ['Hello']) }.to raise_error(RuntimeError, 'agent is required.')
      end
    end

    context 'when the :messages key is not an instance of Llm::MessageContainer' do
      it 'raises an error' do
        expect { client.chat_with_function_calling_loop(agent: agent, messages: ['Hello'], functions: []) }.to raise_error(RuntimeError, 'messages must be an instance of Llm::MessageContainer.')
      end
    end

    it 'performs a loop of function calls and handles their results correctly' do
      function = double('Function', function_name: :function_name, execute_and_generate_message: 'Function result', stop_llm_call?: false, definition: 'function definition')
      allow(Llm::MessageContainer).to receive(:new).and_return(Llm::MessageContainer.new)
      expect(client.chat_with_function_calling_loop(agent: agent, messages: Llm::MessageContainer.new, functions: [function])).to be_a Llm::MessageContainer
    end

    it 'returns the content of the chat messages' do
      function = double('Function', function_name: :function_name, execute_and_generate_message: 'Function result', stop_llm_call?: false, definition: 'function definition')
      allow(Llm::MessageContainer).to receive(:new).and_return(Llm::MessageContainer.new)
      expect(client.chat_with_function_calling_loop(agent: agent, messages: Llm::MessageContainer.new, functions: [function]).string).to eq 'Test user message'
    end
  end
end
