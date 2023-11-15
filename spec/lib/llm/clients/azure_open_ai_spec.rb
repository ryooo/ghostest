require 'spec_helper'

RSpec.describe Llm::Clients::AzureOpenAi do
  describe '#initialize' do
    let(:azure_open_ai) { described_class.new }

    it 'initializes OpenAI::Client with correct parameters' do
      # Mock the OpenAI::Client
      allow(OpenAI::Client).to receive(:new)

      # Call the initialize method
      azure_open_ai

      # Check if OpenAI::Client was initialized with correct parameters
      expect(OpenAI::Client).to have_received(:new).with(
        api_type: :azure,
        api_version: ENV['AZURE_API_VERSION'],
        access_token: ENV['AZURE_OPENAI_API_KEY'],
        uri_base: "#{ENV['AZURE_API_BASE']}/openai/deployments/#{ENV['AZURE_DEPLOYMENT_NAME']}",
        request_timeout: 30000
      )
    end

    it 'assigns @client as an instance of OpenAI::Client' do
      # Mock the OpenAI::Client
      mock_client = double(OpenAI::Client)
      allow(OpenAI::Client).to receive(:new).and_return(mock_client)

      # Call the initialize method
      azure_open_ai

      # Check if @client is an instance of OpenAI::Client
      expect(azure_open_ai.instance_variable_get(:@client)).to eq(mock_client)
    end

    it 'raises KeyError when environment variables are not set' do
      # Unset the environment variables
      ENV['AZURE_API_VERSION'] = nil
      ENV['AZURE_OPENAI_API_KEY'] = nil
      ENV['AZURE_API_BASE'] = nil
      ENV['AZURE_DEPLOYMENT_NAME'] = nil

      # Expect 'KeyError' to be raised
      expect { azure_open_ai }.to raise_error(KeyError)
    end
  end
end
