require 'spec_helper'

RSpec.describe Llm::Functions::ReadFile do
  let(:read_file) { Llm::Functions::ReadFile.new }

  describe '#function_name' do
    it 'returns the correct function name' do
      expect(read_file.function_name).to eq(:read_file)
    end
  end

  describe '#definition' do
    it 'returns the correct definition' do
      expect(read_file.definition).to eq({
        name: :read_file,
        description: I18n.t("ghostest.functions.read_file.description"),
        parameters: {
          type: :object,
          properties: {
            filepath: {
              type: :string,
              description: I18n.t("ghostest.functions.read_file.parameters.filepath"),
            },
          },
          required: [:filepath],
        },
      })
    end
  end

  describe '#execute_and_generate_message' do
    context 'when a valid file path is provided' do
      let(:file_path) { 'spec/dummy/test_file.txt' }

      before do
        File.open(file_path, 'w') { |file| file.write('Test content') }
      end

      after do
        File.delete(file_path)
      end

      it 'returns the correct file content' do
        result = read_file.execute_and_generate_message(filepath: file_path)
        expect(result[:file_contents]).to eq('Test content')
      end
    end

    context 'when an invalid file path is provided' do
      let(:file_path) { 'invalid/path.txt' }

      it 'returns an error message' do
        result = read_file.execute_and_generate_message(filepath: file_path)
        expect(result[:error]).to eq('File not found.')
      end
    end
  end
end
