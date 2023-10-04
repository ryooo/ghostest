require 'spec_helper'

RSpec.describe Llm::Functions::GetGemFilesList do
  let(:function) { described_class.new }

  describe '#function_name' do
    it 'returns the correct function name' do
      expect(function.function_name).to eq :get_gem_files_list
    end
  end

  describe '.gem_name_enums' do
    it 'returns the correct list of gem names' do
      expect(described_class.gem_name_enums).to eq Bundler.locked_gems.specs.map(&:full_name)
    end
  end

  describe '#definition' do
    it 'returns the correct function definition' do
      definition = function.definition
      expect(definition[:name]).to eq :get_gem_files_list
      expect(definition[:description]).to eq I18n.t('ghostest.functions.get_gem_files_list.description')
      expect(definition[:parameters][:type]).to eq :object
      expect(definition[:parameters][:properties][:gem_name][:type]).to eq :string
      expect(definition[:parameters][:properties][:gem_name][:description]).to eq I18n.t('ghostest.functions.get_gem_files_list.parameters.gem_name')
      expect(definition[:parameters][:properties][:gem_name][:enum]).to eq described_class.gem_name_enums
      expect(definition[:parameters][:required]).to eq [:gem_name]
    end
  end

  describe '#execute_and_generate_message' do
    it 'executes the function and generates a correct message with a given gem name' do
      gem_name = described_class.gem_name_enums.first
      files_list = Dir.glob("#{Gem.paths.home}/gems/#{gem_name}/**/*.{rb,yml}")
      result = function.execute_and_generate_message('gem_name' => gem_name)
      expect(result[:files_list]).to eq files_list
    end

    it 'raises an error when given an invalid gem name' do
      invalid_gem_name = 'invalid_gem_name'
      expect { function.execute_and_generate_message('gem_name' => invalid_gem_name) }.to raise_error(Ghostest::Error)
    end
  end
end
