require 'spec_helper'
require 'open3'

module Llm
  module Functions
    RSpec.describe ExecRspecTest, type: :model do
      let(:exec_rspec_test) { ExecRspecTest.new }

      describe '#function_name' do
        it 'returns :exec_rspec_test' do
          expect(exec_rspec_test.function_name).to eq :exec_rspec_test
        end
      end

      describe '#definition' do
        it 'returns the correct function definition' do
          expected_definition = {
            name: :exec_rspec_test,
            description: I18n.t("ghostest.functions.exec_rspec_test.description"),
            parameters: {
              type: :object,
              properties: {
                file_or_dir_path: {
                  type: :string,
                  description: I18n.t("ghostest.functions.exec_rspec_test.parameters.file_or_dir_path"),
                },
              },
              required: [:file_or_dir_path],
            },
          }
          expect(exec_rspec_test.definition).to eq expected_definition
        end
      end

      describe '#execute_and_generate_message' do
        context 'when file_or_dir_path is nil' do
          it 'raises an error' do
            expect { exec_rspec_test.execute_and_generate_message({ 'file_or_dir_path': nil }) }.to raise_error(Ghostest::Error, 'Please specify the file or directory path.')
          end
        end

        context 'when file_or_dir_path is an empty string' do
          it 'raises an error' do
            expect { exec_rspec_test.execute_and_generate_message({ 'file_or_dir_path': '' }) }.to raise_error(Ghostest::Error, 'Please specify the file or directory path.')
          end
        end

        context 'when file_or_dir_path is not a valid file or directory path' do
          let(:stdout) { '' }
          let(:stderr) { "No such file or directory - #{invalid_path}" }
          let(:exit_status) { 1 }
          let(:invalid_path) { 'invalid_path' }

          before do
            allow(Open3).to receive(:capture3).and_return([stdout, stderr, instance_double(Process::Status, exitstatus: exit_status)])
          end

          it 'does not raise an error' do
            expect { exec_rspec_test.execute_and_generate_message({ 'file_or_dir_path': invalid_path }) }.not_to raise_error
          end

          it 'returns the expected stdout, stderr, and exit status' do
            result = exec_rspec_test.execute_and_generate_message({ 'file_or_dir_path': invalid_path })
            expect(result).to eq({ stdout: stdout, stderr: stderr, exit_status: exit_status })
          end
        end

        context 'when file_or_dir_path is a valid file or directory path' do
          let(:dummy_spec_file_path) { 'spec/dummy/dummy_spec.rb' }
          let(:stdout) do 'Finished in 0.00038 seconds (files took 0.08843 seconds to load)
1 example, 0 failures' end
          let(:stderr) { '' }
          let(:exit_status) { 0 }

          before do
            allow(Open3).to receive(:capture3).and_return([stdout, stderr, instance_double(Process::Status, exitstatus: exit_status)])
          end

          it 'executes the rspec tests and returns the stdout, stderr, and exit status' do
            result = exec_rspec_test.execute_and_generate_message({ 'file_or_dir_path': dummy_spec_file_path })
            expect(result).to eq({ stdout: stdout, stderr: stderr, exit_status: exit_status })
          end
        end
      end
    end
  end
end
