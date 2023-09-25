require 'spec_helper'

module Llm
  module Functions
    RSpec.describe OverwriteFile, type: :model do
      let(:overwrite_file) { OverwriteFile.new }

      describe '#execute_and_generate_message' do
        context 'when the file exists' do
          let(:filepath) { 'spec/dummy/dummy_file.txt' }

          before do
            File.open(filepath, 'w') { |file| file.write('This is a dummy file.') }
          end

          it 'overwrites the file with the new text and returns a success message' do
            new_text = 'This is a new text.'
            result = overwrite_file.execute_and_generate_message(filepath:, new_text:)
            expect(result).to eq({ result: :success })
            expect(File.read(filepath)).to eq(new_text)
          end

          it 'handles and overwrites files with various content' do
            new_texts = ['Text with special characters: !@#$%^&*()', 'Multiline\ntext', 'Text with spaces    ']
            new_texts.each do |new_text|
              result = overwrite_file.execute_and_generate_message(filepath:, new_text:)
              expect(result).to eq({ result: :success })
              expect(File.read(filepath)).to eq(new_text)
            end
          end

          context 'when the file is empty' do
            before do
              File.open(filepath, 'w') { |file| file.write('') }
            end

            it 'overwrites the file with the new text and returns a success message' do
              new_text = 'This is a new text.'
              result = overwrite_file.execute_and_generate_message(filepath:, new_text:)
              expect(result).to eq({ result: :success })
              expect(File.read(filepath)).to eq(new_text)
            end
          end

          after do
            File.delete(filepath) if File.exist?(filepath)
          end
        end

        context 'when the file does not exist' do
          it 'raises an error' do
            expect { overwrite_file.execute_and_generate_message(filepath: 'non_existent_file.txt', new_text: 'This is a new text.') }.to raise_error(Ghostest::Error, 'File not found: non_existent_file.txt')
          end
        end
      end
    end
  end
end
