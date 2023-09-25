require 'spec_helper'

RSpec.describe Llm::Functions::FixOneRspecTest do

  describe '#function_name' do
    it 'returns the correct function name' do
      expect(subject.function_name).to eq :fix_one_rspec_test
    end
  end

  describe '#definition' do
    it 'returns the correct definition' do
      expect(subject.definition).to include(
        name: :fix_one_rspec_test,
        description: I18n.t('functions.fix_one_rspec_test.description'),
        parameters: {
          type: :object,
          properties: {
            file_path: {
              type: :string,
              description: I18n.t('functions.fix_one_rspec_test.parameters.file_path'),
            },
            line_num: {
              type: :string,
              description: I18n.t('functions.fix_one_rspec_test.parameters.line_num'),
            },
          },
          required: [:file_path, :line_num],
        }
      )
    end
  end

  describe '#execute_and_generate_message' do
    context 'when the file path is not provided, empty, or the file does not exist' do
      it 'raises an error' do
        expect { subject.execute_and_generate_message({}) }.to raise_error(Ghostest::Error, 'Please specify the file path.')
        expect { subject.execute_and_generate_message({ file_path: '' }) }.to raise_error(Ghostest::Error, 'Please specify the file path.')
        expect { subject.execute_and_generate_message({ file_path: 'non_existent_file.rb' }) }.to raise_error(Ghostest::Error, 'Please specify the file path.')
      end
    end

    context 'when the line number is less than 1' do
      before do
        allow(File).to receive(:exist?).and_return(true)
      end

      it 'raises an error' do
        expect { subject.execute_and_generate_message({ file_path: 'dummy_file.rb', line_num: '0' }) }.to raise_error(Ghostest::Error, 'Please specify the line num. 0')
      end
    end

    context 'when the file path and line number are correctly provided' do
      before do
        allow(File).to receive(:exist?).and_return(true)
      end

      it 'executes the rspec script and returns the correct output' do
        allow(Open3).to receive(:capture3).and_return(['stdout', 'stderr', instance_double(Process::Status, exitstatus: 0)])

        result = subject.execute_and_generate_message({ file_path: 'dummy_file.rb', line_num: '1' })

        expect(result).to eq({ stdout: 'stdout', stderr: 'stderr', exit_status: 0 })
      end
    end

    context 'when the rspec test fails' do
      before do
        allow(File).to receive(:exist?).and_return(true)
      end

      it 'returns the correct output' do
        allow(Open3).to receive(:capture3).and_return(['failure stdout', 'failure stderr', instance_double(Process::Status, exitstatus: 1)])

        result = subject.execute_and_generate_message({ file_path: 'spec/dummy/failing_test_spec.rb', line_num: '3' })

        expect(result).to eq({ stdout: 'failure stdout', stderr: 'failure stderr', exit_status: 1 })
      end
    end

    context 'when the rspec test passes' do
      before do
        allow(File).to receive(:exist?).and_return(true)
      end

      it 'returns the correct output' do
        allow(Open3).to receive(:capture3).and_return(['success stdout', 'success stderr', instance_double(Process::Status, exitstatus: 0)])

        result = subject.execute_and_generate_message({ file_path: 'spec/dummy/passing_test_spec.rb', line_num: '3' })

        expect(result).to eq({ stdout: 'success stdout', stderr: 'success stderr', exit_status: 0 })
      end
    end
  end
end
