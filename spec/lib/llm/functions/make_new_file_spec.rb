require 'spec_helper'

RSpec.describe Llm::Functions::MakeNewFile do
  let(:make_new_file) { described_class.new }

  describe '#execute_and_generate_message' do
    context 'when the directory exists' do
      it 'creates a new file successfully' do
        args = { filepath: 'spec/dummy/test_file.txt', file_contents: 'This is a test file.' }
        result = make_new_file.execute_and_generate_message(args)
        expect(result[:result]).to eq('success')
        expect(File.exist?(args[:filepath])).to be true
        File.delete(args[:filepath]) if File.exist?(args[:filepath])
      end
    end

    context 'when the directory does not exist' do
      it 'creates a new file and the directory successfully' do
        args = { filepath: 'spec/dummy/new_dir/test_file.txt', file_contents: 'This is a test file.' }
        result = make_new_file.execute_and_generate_message(args)
        expect(result[:result]).to eq('success')
        expect(File.exist?(args[:filepath])).to be true
        FileUtils.rm_rf('spec/dummy/new_dir') if Dir.exist?('spec/dummy/new_dir')
      end
    end

    it 'writes the specified content to the new file' do
      args = { filepath: 'spec/dummy/test_file.txt', file_contents: 'This is a test file.' }
      make_new_file.execute_and_generate_message(args)
      expect(File.read(args[:filepath])).to eq(args[:file_contents])
      File.delete(args[:filepath]) if File.exist?(args[:filepath])
    end
  end
end
