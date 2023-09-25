require 'spec_helper'

RSpec.describe Ghostest::Languages::Ruby do
  describe '.convert_source_path_to_test_path' do
    it 'converts a source file path to a test file path' do
      source_path = 'lib/ghostest/languages/ruby.rb'
      expect(described_class.convert_source_path_to_test_path(source_path)).to eq 'spec/lib/ghostest/languages/ruby_spec.rb'
    end
  end

  describe '.test_condition_yml_path' do
    it 'returns the path to the test condition yml file' do
      expect(described_class.test_condition_yml_path).to eq 'spec/ghostest_condition.yml'
    end
  end

  describe '.create_functions' do
    it 'returns an array of new instances of the necessary functions' do
      expect(described_class.create_functions.map(&:class)).to eq [Llm::Functions::ExecRspecTest, Llm::Functions::GetGemFilesList]
    end
  end
end
