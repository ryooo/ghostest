require 'spec_helper'

RSpec.describe Llm::Functions::OpenUrl do
  let(:open_url) { Llm::Functions::OpenUrl.new }

  describe '#function_name' do
    it 'returns :open_url' do
      expect(open_url.function_name).to eq :open_url
    end
  end

  describe '#definition' do
    it 'returns the correct hash' do
      expect(open_url.definition).to eq({
        name: :open_url,
        description: I18n.t('ghostest.functions.open_url.description'),
        parameters: {
          type: :object,
          properties: {
            url: {
              type: :string,
              description: I18n.t('ghostest.functions.open_url.parameters.url'),
            },
            what_i_want_to_know: {
              type: :string,
              description: I18n.t('ghostest.functions.open_url.parameters.what_i_want_to_know'),
            },
          },
          required: [:url, :what_i_want_to_know],
        },
      })
    end
  end

  describe '#execute_and_generate_message' do
    it 'raises an error if :url or :what_i_want_to_know is not present in args' do
      expect { open_url.execute_and_generate_message({}) }.to raise_error(RuntimeError)
    end

    it 'returns the correct hash when given a valid URL' do
      # Mock the classes used in the method
      allow(URI).to receive(:open).and_return('HTML content')
      allow(Nokogiri::HTML).to receive(:parse).and_return(Nokogiri::HTML('<html><head><title>Example Domain</title></head><body>HTML content</body></html>'))
      allow(HTMLPage).to receive(:new).and_return(double('HTMLPage', markdown: 'Markdown content'))

      result = open_url.execute_and_generate_message({ url: 'http://example.com', what_i_want_to_know: 'dummy' })

      expect(result).to eq({
        url: 'http://example.com',
        title: 'Example Domain',
        page_content: 'Markdown content',
      })
    end

    it 'correctly splits the content into chunks and sends each chunk to the Azure OpenAI for summarization when the size of the markdown content is larger than 25,000' do
      # Mock the classes used in the method
      allow(URI).to receive(:open).and_return('HTML content')
      allow(Nokogiri::HTML).to receive(:parse).and_return(Nokogiri::HTML('<html><head><title>Example Domain</title></head><body>HTML content</body></html>'))
      allow(HTMLPage).to receive(:new).and_return(double('HTMLPage', markdown: 'M' * 25001))
      allow(Llm::Clients::AzureOpenAi).to receive(:new).and_return(double('AzureOpenAi', chat: { "choices" => [{ "message" => { "content" => 'Summarized content' } }] }))

      result = open_url.execute_and_generate_message({ url: 'http://example.com', what_i_want_to_know: 'dummy' })

      expect(result).to eq({
        url: 'http://example.com',
        title: 'Example Domain',
        page_content: "Summarized content\n\nSummarized content",
      })
    end

    it 'raises an error if url is nil or empty' do
      expect { open_url.execute_and_generate_message({ url: nil, what_i_want_to_know: 'dummy' }) }.to raise_error(RuntimeError)
      expect { open_url.execute_and_generate_message({ url: '', what_i_want_to_know: 'dummy' }) }.to raise_error(RuntimeError)
    end

    it 'returns the correct hash when url is valid and the size of the markdown content is less than 25,000' do
      # Mock the classes used in the method
      allow(URI).to receive(:open).and_return('HTML content')
      allow(Nokogiri::HTML).to receive(:parse).and_return(Nokogiri::HTML('<html><head><title>Example Domain</title></head><body>HTML content</body></html>'))
      allow(HTMLPage).to receive(:new).and_return(double('HTMLPage', markdown: 'Markdown content'))

      result = open_url.execute_and_generate_message({ url: 'http://example.com', what_i_want_to_know: 'dummy' })

      expect(result).to eq({
        url: 'http://example.com',
        title: 'Example Domain',
        page_content: 'Markdown content',
      })
    end

    it 'returns the correct hash when url is valid and the size of the markdown content is larger than 25,000' do
      # Mock the classes used in the method
      allow(URI).to receive(:open).and_return('HTML content')
      allow(Nokogiri::HTML).to receive(:parse).and_return(Nokogiri::HTML('<html><head><title>Example Domain</title></head><body>HTML content</body></html>'))
      allow(HTMLPage).to receive(:new).and_return(double('HTMLPage', markdown: 'M' * 25001))
      allow(Llm::Clients::AzureOpenAi).to receive(:new).and_return(double('AzureOpenAi', chat: { "choices" => [{ "message" => { "content" => 'Summarized content' } }] }))

      result = open_url.execute_and_generate_message({ url: 'http://example.com', what_i_want_to_know: 'dummy' })

      expect(result).to eq({
        url: 'http://example.com',
        title: 'Example Domain',
        page_content: "Summarized content\n\nSummarized content",
      })
    end

    it 'raises an error when invalid URL is provided' do
      allow(Addressable::URI).to receive(:parse).and_raise(Addressable::URI::InvalidURIError)
      expect { open_url.execute_and_generate_message({ url: 'invalid_url', what_i_want_to_know: 'dummy' }) }.to raise_error(Addressable::URI::InvalidURIError)
    end

    it 'raises an error when the Azure OpenAI service is not available or returns an error' do
      allow(URI).to receive(:open).and_return('HTML content')
      allow(Nokogiri::HTML).to receive(:parse).and_return(Nokogiri::HTML('<html><head><title>Example Domain</title></head><body>HTML content</body></html>'))
      allow(HTMLPage).to receive(:new).and_return(double('HTMLPage', markdown: 'M' * 25001))
      allow(Llm::Clients::AzureOpenAi).to receive(:new).and_return(double('AzureOpenAi', chat: { 'error' => { 'message' => 'An error occurred' } }))

      expect { open_url.execute_and_generate_message({ url: 'http://example.com', what_i_want_to_know: 'dummy' }) }.to raise_error(RuntimeError)
    end

    it 'returns the correct hash when url is valid but the page does not contain any content' do
      # Mock the classes used in the method
      allow(URI).to receive(:open).and_return('')
      allow(Nokogiri::HTML).to receive(:parse).and_return(Nokogiri::HTML('<html><head><title>Example Domain</title></head><body></body></html>'))
      allow(HTMLPage).to receive(:new).and_return(double('HTMLPage', markdown: ''))

      result = open_url.execute_and_generate_message({ url: 'http://example.com', what_i_want_to_know: 'dummy' })

      expect(result).to eq({
        url: 'http://example.com',
        title: 'Example Domain',
        page_content: '',
      })
    end

    it 'returns the correct hash when url is valid but the page is not in HTML format' do
      # Mock the classes used in the method
      allow(URI).to receive(:open).and_return('Non-HTML content')
      allow(Nokogiri::HTML).to receive(:parse).and_return(Nokogiri::HTML('Non-HTML content'))
      allow(HTMLPage).to receive(:new).and_return(double('HTMLPage', markdown: 'Non-HTML content'))

      result = open_url.execute_and_generate_message({ url: 'http://example.com', what_i_want_to_know: 'dummy' })

      expect(result).to eq({
        url: 'http://example.com',
        title: nil,
        page_content: 'Non-HTML content',
      })
    end
  end
end
