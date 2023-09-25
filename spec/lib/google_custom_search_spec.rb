require 'spec_helper'

RSpec.describe GoogleCustomSearch do
  let(:google_search) { GoogleCustomSearch.new }
  let(:query) { 'test query' }
  let(:args) { { hl: 'en' } }
  let(:service) { instance_double('Google::Apis::CustomsearchV1::CustomSearchAPIService') }
  let(:authorizer) { instance_double('Signet::OAuth2::Client') }

  before do
    allow(Google::Apis::CustomsearchV1::CustomSearchAPIService).to receive(:new).and_return(service)
    allow(service).to receive(:authorization=)
    allow(service).to receive(:list_cses)
    allow(Signet::OAuth2::Client).to receive(:new).and_return(authorizer)
    allow(authorizer).to receive(:configure_connection).and_return(authorizer)
    allow(authorizer).to receive(:fetch_access_token!)
  end

  describe '#search' do
    context 'when called with a query' do
      it 'calls the Google API with the correct parameters' do
        google_search.search(query, args)
        expect(service).to have_received(:list_cses).with(cx: ENV['GOOGLE_CUSTOM_SEARCH_CSE_ID'], q: query, **args)
      end
    end
  end

  describe '#service' do
    it 'creates and memoizes a new instance of Google API service with the correct authorization' do
      google_search.service
      expect(Google::Apis::CustomsearchV1::CustomSearchAPIService).to have_received(:new)
      expect(authorizer).to have_received(:fetch_access_token!)
      expect(service).to have_received(:authorization=).with(authorizer)
    end
  end

  describe '#make_authorizer' do
    it 'creates a new instance of Signet::OAuth2::Client with the correct parameters' do
      google_search.make_authorizer
      expect(Signet::OAuth2::Client).to have_received(:new)
      expect(authorizer).to have_received(:configure_connection)
    end
  end

  context 'when environment variables are not set' do
    it 'raises a KeyError' do
      allow(ENV).to receive(:fetch).and_raise(KeyError)
      expect { google_search.search(query, args) }.to raise_error(KeyError)
    end
  end

  context 'when Google API service or Signet::OAuth2::Client throws an error' do
    it 'raises an error' do
      allow(service).to receive(:list_cses).and_raise(StandardError)
      expect { google_search.search(query, args) }.to raise_error(StandardError)
    end
  end

  context 'when Google API service returns different responses' do
    let(:response) { double('response') }

    it 'returns the response from the Google API' do
      allow(service).to receive(:list_cses).and_return(response)
      expect(google_search.search(query, args)).to eq(response)
    end
  end
end
