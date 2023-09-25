require 'spec_helper'

RSpec.describe I18nTranslator, type: :model do
  let(:from_locale) { 'ja' }
  let(:to_locales) { ['en'] }
  let(:from_hash) { { 'ja' => { 'hello' => 'こんにちは' } } }
  let(:to_hash) { { 'en' => { 'hello' => 'Hello' } } }
  before do
    allow(I18nTranslator).to receive(:translate).with("こんにちは").and_return('Hello')
  end

  describe '.update_dictionary!' do
    before do
      allow(I18n).to receive(:load_path).and_return(['config/locales/ja.yml'])
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:read).and_return(from_hash.to_yaml)
      allow(File).to receive(:write)
    end

    it 'updates the respective translation files' do
      I18nTranslator.update_dictionary!(from_locale, to_locales)
      expect(File).to have_received(:write)
    end

    context 'when the to_locale file does not exist' do
      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it 'creates a new file and writes the translations into it' do
        I18nTranslator.update_dictionary!(from_locale, to_locales)
        expect(File).to have_received(:write)
      end
    end

    context 'when the to_locale file exists' do
      it 'updates the existing translations in the file' do
        I18nTranslator.update_dictionary!(from_locale, to_locales)
        expect(File).to have_received(:write)
      end
    end

    context 'when the from_locale file does not exist' do
      before do
        allow(I18n).to receive(:load_path).and_return([])
      end

      it 'does not raise an error' do
        expect { I18nTranslator.update_dictionary!(from_locale, to_locales) }.not_to raise_error
      end
    end
  end

  describe '.deep_translate' do
    it 'recursively translates the nested values of the from_hash into the to_hash' do
      result = I18nTranslator.deep_translate(from_hash, to_hash, from_locale, to_locales.first)
      expect(result).to eq({ "ja" => { "hello" => "Hello", "hello_md5" => "c0e89a293bd36c7a768e4e9d2c5475a8" } })
    end

    context 'when the to_hash does not contain a translation for a key in the from_hash' do
      let(:to_hash) { {} }

      it 'adds the translation to the to_hash' do
        result = I18nTranslator.deep_translate(from_hash, to_hash, from_locale, to_locales.first)
        expect(result).to eq({ "ja" => { "hello" => "Hello", "hello_md5" => "c0e89a293bd36c7a768e4e9d2c5475a8" } })
      end
    end

    context 'when the to_hash contains a translation for a key in the from_hash' do
      it 'updates the translation in the to_hash' do
        result = I18nTranslator.deep_translate(from_hash, to_hash, from_locale, to_locales.first)
        expect(result).to eq({ "ja" => { "hello" => "Hello", "hello_md5" => "c0e89a293bd36c7a768e4e9d2c5475a8" } })
      end
    end

    context 'when the md5 hash of the translation string has not changed' do
      let(:to_hash) { { 'en' => { 'hello' => 'Hello', 'hello_md5' => 'c0e89a293bd36c7a768e4e9d2c5475a8' } } }

      it 'does not overwrite the existing translation' do
        result = I18nTranslator.deep_translate(from_hash, to_hash, from_locale, to_locales.first)
        expect(result).to eq({ 'ja' => { "hello" => "Hello", "hello_md5" => "c0e89a293bd36c7a768e4e9d2c5475a8" } })
      end
    end

    context 'when the from_hash is empty' do
      let(:from_hash) { {} }

      it 'returns an empty hash' do
        result = I18nTranslator.deep_translate(from_hash, to_hash, from_locale, to_locales.first)
        expect(result).to eq({})
      end
    end

    context 'when the from_hash contains non-string values' do
      let(:from_hash) { { 'ja' => { 'hello' => 123 } } }

      it 'raises an error' do
        expect { I18nTranslator.deep_translate(from_hash, to_hash, from_locale, to_locales.first) }.to raise_error(TypeError)
      end
    end
  end
end
