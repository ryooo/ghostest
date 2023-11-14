require 'spec_helper'

RSpec.describe Llm::Clients::Base, type: :client do
  let(:client) do
    mock_client = Llm::Clients::AzureOpenAi.new
    allow(mock_client.client).to receive(:chat).and_return({ choices: [{ message: { role: :user, content: 'Test user message' } }] })
    mock_client
  end
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

    context 'when the parameters hash contains :temperature, :top_p, :frequency_penalty, :presence_penalty keys' do
      it 'does not overwrite their values' do
        parameters = { messages: ['Hello'], temperature: 0.6, top_p: 0.9, frequency_penalty: 0.1, presence_penalty: 0.2 }
        expect(client.client).to receive(:chat).with(parameters: parameters)
        client.chat(parameters: parameters)
      end
    end

    context 'when the parameters hash contains keys other than :messages, :temperature, :top_p, :frequency_penalty, :presence_penalty' do
      it 'includes them in the parameters for the chat method of the @client object' do
        parameters = { messages: ['Hello'], extra_key: 'extra_value' }
        expected_parameters = { messages: ['Hello'], extra_key: 'extra_value', temperature: 0.5, top_p: 1, frequency_penalty: 0, presence_penalty: 0 }
        expect(client.client).to receive(:chat).with(parameters: expected_parameters)
        client.chat(parameters: parameters)
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
        expect { client.chat_with_function_calling_loop(agent:, messages: ['Hello'], functions: []) }.to raise_error(RuntimeError, 'messages must be an instance of Llm::MessageContainer.')
      end
    end

    context 'when args is an empty hash' do
      it 'raises an error' do
        expect { client.chat_with_function_calling_loop({}) }.to raise_error(RuntimeError, 'agent is required.')
      end
    end

    context 'when args has messages key as an instance of Llm::MessageContainer' do
      it 'does not create a new Llm::MessageContainer' do
        message_container = Llm::MessageContainer.new
        expect(Llm::MessageContainer).not_to receive(:new)
        client.chat_with_function_calling_loop(agent:, messages: message_container, functions: [])
      end
    end

    context 'when args has messages key as not an instance of Llm::MessageContainer' do
      it 'creates a new Llm::MessageContainer and adds the messages to it' do
        expect(Llm::MessageContainer).to receive(:new).and_call_original
        client.chat_with_function_calling_loop(agent:, messages: ['Hello'], functions: [])
      end
    end

    context 'when finish_reason is not function_call' do
      it 'breaks the loop' do
        allow(client.client).to receive(:chat).and_return({ choices: [{ finish_reason: 'not_function_call', message: { role: :user, content: 'Test user message' } }] })
        expect(client.chat_with_function_calling_loop(agent:, messages: Llm::MessageContainer.new, functions: []).string).to eq 'Test user message'
      end
    end

    context 'when content key in the response of chat method call is not nil' do
      it 'writes the content to chat_message_io' do
        allow(client.client).to receive(:chat).and_return({ choices: [{ finish_reason: 'function_call', message: { role: :user, content: 'Test user message' } }] })
        expect(client.chat_with_function_calling_loop(agent:, messages: Llm::MessageContainer.new, functions: []).string).to eq 'Test user message'
      end
    end

    context 'when content key in the response of the second chat method call is not nil' do
      it 'writes the content to chat_message_io' do
        allow(client.client).to receive(:chat).and_return({ choices: [{ finish_reason: 'function_call', message: { role: :user, content: 'Test user message' } }] }, { choices: [{ finish_reason: 'not_function_call', message: { role: :user, content: 'Test user message 2' } }] })
        expect(client.chat_with_function_calling_loop(agent:, messages: Llm::MessageContainer.new, functions: []).string).to eq 'Test user message2'
      end
    end

    context 'when content key in the response of the second chat method call is nil' do
      it 'prints the response and exit with status 1' do
        allow(client.client).to receive(:chat).and_return({ choices: [{ finish_reason: 'function_call', message: { role: :user, content: 'Test user message' } }] }, { choices: [{ finish_reason: 'not_function_call', message: { role: :user, content: nil } }] })
        expect { client.chat_with_function_calling_loop(agent:, messages: Llm::MessageContainer.new, functions: []) }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq 1
        end
      end
    end

    it 'performs a loop of function calls and handles their results correctly' do
      function = double('Function', function_name: :function_name, execute_and_generate_message: 'Function result', stop_llm_call?: false, definition: 'function definition')
      allow(Llm::MessageContainer).to receive(:new).and_return(Llm::MessageContainer.new)
      expect(client.chat_with_function_calling_loop(agent:, messages: Llm::MessageContainer.new, functions: [function])).to be_a Llm::MessageContainer
    end

    it 'returns the content of the chat messages' do
      function = double('Function', function_name: :function_name, execute_and_generate_message: 'Function result', stop_llm_call?: false, definition: 'function definition')
      allow(Llm::MessageContainer).to receive(:new).and_return(Llm::MessageContainer.new)
      expect(client.chat_with_function_calling_loop(agent:, messages: Llm::MessageContainer.new, functions: [function]).string).to eq 'Test user message'
    end

    context 'when the :agent key is present but its value is not an instance of Llm::Agents::Base' do
      it 'raises an error' do
        function = double('Function', function_name: :function_name, execute_and_generate_message: 'Function result', stop_llm_call?: false, definition: 'function definition')
        expect { client.chat_with_function_calling_loop(agent: 'invalid_agent', messages: Llm::MessageContainer.new, functions: [function]) }.to raise_error(RuntimeError, 'agent must be an instance of Llm::Agents::Base.')
      end
    end

    context 'when the :functions key is missing in the arguments' do
      it 'raises an error' do
        expect { client.chat_with_function_calling_loop(agent:, messages: Llm::MessageContainer.new) }.to raise_error(RuntimeError, 'functions is required.')
      end
    end

    context 'when the :functions key is present but its value is not an array of Llm::Functions::Base instances' do
      it 'raises an error' do
        expect { client.chat_with_function_calling_loop(agent:, messages: Llm::MessageContainer.new, functions: 'invalid_functions') }.to raise_error(RuntimeError, 'functions must be an array of Llm::Functions::Base instances.')
      end
    end

    context 'when the function call returns a truthy stop_llm_call?' do
      it 'stops the loop of function calls and returns the result of the function call' do
        function = double('Function', function_name: :function_name, execute_and_generate_message: 'Function result', stop_llm_call?: true, definition: 'function definition')
        expect(client.chat_with_function_calling_loop(agent:, messages: Llm::MessageContainer.new, functions: [function]).string).to eq 'Function result'
      end
    end

    context 'when the function call returns a falsy stop_llm_call?' do
      it 'continues the loop of function calls' do
        function = double('Function', function_name: :function_name, execute_and_generate_message: 'Function result', stop_llm_call?: false, definition: 'function definition')
        expect(client.chat_with_function_calling_loop(agent:, messages: Llm::MessageContainer.new, functions: [function]).string).to eq 'Test user message'
      end
    end

    context 'when the number of function calls exceeds 20' do
      it 'stops the loop of function calls and returns an error message' do
        function = double('Function', function_name: :function_name, execute_and_generate_message: 'Function result', stop_llm_call?: false, definition: 'function definition')
        allow(client).to receive(:chat).and_return({ choices: [{ message: { role: :system, content: 'Error: Too many function calls.' } }] })
        expect(client.chat_with_function_calling_loop(agent:, messages: Llm::MessageContainer.new, functions: Array.new(21, function)).string).to eq 'Error: Too many function calls.'
      end
    end

    context 'when the chat method of the @client object does not return a :content key in the :message hash' do
      it 'calls the chat method again with switch_assignee and report_bug functions and returns the content of the chat messages' do
        function = double('Function', function_name: :function_name, execute_and_generate_message: 'Function result', stop_llm_call?: false, definition: 'function definition')
        allow(client).to receive(:chat).and_return({ choices: [{ message: { role: :system, content: 'Error: No content in the message.' } }] })
        expect(client.chat_with_function_calling_loop(agent:, messages: Llm::MessageContainer.new, functions: [function]).string).to eq 'Error: No content in the message.'
      end
    end
  end
end
