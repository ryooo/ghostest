require 'spec_helper'

RSpec.describe Llm::Functions::ReportBug do
  let(:report_bug) { Llm::Functions::ReportBug.new }

  describe '#function_name' do
    it 'returns :report_bug' do
      expect(report_bug.function_name).to eq :report_bug
    end
  end

  describe '#definition' do
    it 'returns the correct definition' do
      expected_definition = {
        name: :report_bug,
        description: I18n.t("functions.report_bug.description"),
        parameters: {
          type: :object,
          properties: {
            message: {
              type: :string,
              description: I18n.t("functions.report_bug.parameters.message"),
            },
          },
          required: [:message],
        },
      }
      expect(report_bug.definition).to eq expected_definition
    end
  end

  describe '#execute_and_generate_message' do
    it 'prints the message and terminates the program' do
      message = 'Test message'
      expect { report_bug.execute_and_generate_message('message' => message) }.to output(message + "\n").to_stdout.and raise_error(SystemExit)
    end
  end
end
