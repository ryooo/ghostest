require 'spec_helper'

RSpec.describe Llm::Clients::OpenAi do
  describe '#initialize' do
    let(:timeout) { 300 }
    let(:api_version) { 'v1' }
    let(:api_key) { 'test_key' }
    let(:uri_base) { 'https://openai.com/openai/deployments/chat/completions' }

    subject { described_class.new(timeout: timeout) }

    before do
      allow(ENV).to receive(:fetch).with('OPENAI_API_VERSION').and_return(api_version)
      allow(ENV).to receive(:fetch).with('OPENAI_API_KEY').and_return(api_key)
    end

    it 'initializes a new OpenAI client with necessary parameters' do
      expect(OpenAI::Client).to receive(:new).with(api_version: api_version, access_token: api_key, uri_base: uri_base, request_timeout: timeout)
      subject
    end

    context 'when no timeout parameter is passed' do
      subject { described_class.new }

      it 'sets the request_timeout to the default value of 300' do
        expect(OpenAI::Client).to receive(:new).with(api_version: api_version, access_token: api_key, uri_base: uri_base, request_timeout: 300)
        subject
      end
    end
  end
end
