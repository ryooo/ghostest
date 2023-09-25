require 'spec_helper'

RSpec.describe Llm::Functions::GoogleSearch do
  let(:google_search) { Llm::Functions::GoogleSearch.new }

  describe '.search_client' do
    it 'returns an instance of GoogleCustomSearch' do
      expect(Llm::Functions::GoogleSearch.search_client).to be_an_instance_of(GoogleCustomSearch)
    end

    it 'returns the same instance on subsequent calls' do
      first_call = Llm::Functions::GoogleSearch.search_client
      second_call = Llm::Functions::GoogleSearch.search_client
      expect(first_call).to eq(second_call)
    end
  end

  describe '#function_name' do
    it 'returns :google_search' do
      expect(google_search.function_name).to eq(:google_search)
    end
  end

  describe '#definition' do
    it 'returns a hash with the function definition' do
      expect(google_search.definition).to be_a(Hash)
    end

    it 'returns the same hash on subsequent calls' do
      first_call = google_search.definition
      second_call = google_search.definition
      expect(first_call).to eq(second_call)
    end
  end

  describe '#execute_and_generate_message' do
    context 'when :search_word is nil or empty' do
      it 'raises an error' do
        expect { google_search.execute_and_generate_message({}) }.to raise_error(Ghostest::Error, 'Search word is empty')
        expect { google_search.execute_and_generate_message({ search_word: '' }) }.to raise_error(Ghostest::Error, 'Search word is empty')
      end
    end

    context 'when :search_word is provided' do
      let(:search_word) { 'test' }
      let(:search_results) { double('SearchResults', items: []) }

      before do
        allow(Llm::Functions::GoogleSearch.search_client).to receive(:search).with(search_word, gl: 'jp').and_return(search_results)
      end

      it 'returns an array of search results' do
        expect(google_search.execute_and_generate_message({ search_word: })).to eq([])
      end

      context 'and the search results are not empty' do
        let(:item) { double('Item', title: 'Test Title', formatted_url: 'http://test.com', html_snippet: 'Test Snippet') }
        let(:search_results) { double('SearchResults', items: [item]) }

        it 'returns an array of search results with the correct format' do
          expect(google_search.execute_and_generate_message({ search_word: })).to eq([{ title: 'Test Title', url: 'http://test.com', snippet: 'Test Snippet' }])
        end

        it 'correctly extracts the title, url, and snippet from the search results' do
          result = google_search.execute_and_generate_message({ search_word: })[0]
          expect(result[:title]).to eq('Test Title')
          expect(result[:url]).to eq('http://test.com')
          expect(result[:snippet]).to eq('Test Snippet')
        end
      end
    end
  end
end
