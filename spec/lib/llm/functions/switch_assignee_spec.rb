require 'spec_helper'
require 'llm/functions/switch_assignee'

RSpec.describe Llm::Functions::SwitchAssignee do
  let(:assignee) { double('Assignee', name_with_type: 'Mr_tester(tester)') }
  let(:agent1) { double('Agent1', name_with_type: 'Mr_reviewer(reviewer)') }
  let(:agent2) { double('Agent2', name_with_type: 'Mr_tester(tester)') }
  let(:agents) { [agent1, agent2] }

  subject { described_class.new(assignee, agents) }

  describe '#initialize' do
    it 'sets the assignee, agents, and valid_agents' do
      expect(subject.instance_variable_get(:@assignee)).to eq assignee
      expect(subject.instance_variable_get(:@agents)).to eq agents
      expect(subject.instance_variable_get(:@valid_agents)).to eq agents.map(&:name_with_type)
    end
  end

  describe '#function_name' do
    it 'returns :switch_assignee' do
      expect(subject.function_name).to eq :switch_assignee
    end
  end

  describe '#stop_llm_call?' do
    it 'always returns true' do
      expect(subject.stop_llm_call?).to be true
    end
  end

  describe '#last_message' do
    it 'returns the last message in the messages array' do
      message1 = { name: 'Mr_tester(tester)', next_assignee: 'Mr_reviewer(reviewer)', message: 'Message 1' }
      message2 = { name: 'Mr_reviewer(reviewer)', next_assignee: 'Mr_tester(tester)', message: 'Message 2' }
      subject.instance_variable_set(:@messages, [message1, message2])
      expect(subject.last_message).to eq 'Message 2'
    end
  end

  describe '#last_assignee' do
    it 'returns the last assignee in the messages array' do
      message1 = { name: 'Mr_tester(tester)', next_assignee: 'Mr_reviewer(reviewer)', message: 'Message 1' }
      message2 = { name: 'Mr_reviewer(reviewer)', next_assignee: 'Mr_tester(tester)', message: 'Message 2' }
      subject.instance_variable_set(:@messages, [message1, message2])
      expect(subject.last_assignee).to eq 'Mr_reviewer(reviewer)'
    end
  end

  describe '#definition' do
    it 'returns the correct function definition' do
      definition = {
        name: :switch_assignee,
        description: I18n.t("functions.switch_assignee.description"),
        parameters: {
          type: :object,
          properties: {
            next_assignee: {
              type: :string,
              description: I18n.t("functions.switch_assignee.parameters.next_assignee"),
              enum: ['Mr_reviewer(reviewer)'],
            },
            message: {
              type: :string,
              description: I18n.t("functions.switch_assignee.parameters.message"),
            },
          },
          required: [:assignee, :message],
        },
      }
      expect(subject.definition).to eq definition
    end
  end

  describe '#execute_and_generate_message' do
    context 'with valid arguments' do
      it 'executes the function and generates a message' do
        args = { next_assignee: 'Mr_reviewer(reviewer)', message: 'Test message' }
        message = { name: 'Mr_tester(tester)', next_assignee: 'Mr_reviewer(reviewer)', message: 'Test message' }
        expect(subject.execute_and_generate_message(args)).to eq message
      end
    end

    context 'with invalid arguments' do
      it 'raises an error when next_assignee is nil' do
        args = { next_assignee: nil, message: 'Test message' }
        expect { subject.execute_and_generate_message(args) }.to raise_error(Ghostest::Error, 'next_assignee is required')
      end

      it 'raises an error when next_assignee is empty' do
        args = { next_assignee: '', message: 'Test message' }
        expect { subject.execute_and_generate_message(args) }.to raise_error(Ghostest::Error, 'next_assignee is required')
      end

      it 'raises an error when message is nil' do
        args = { next_assignee: 'Mr_reviewer(reviewer)', message: nil }
        expect { subject.execute_and_generate_message(args) }.to raise_error(Ghostest::Error, 'message is required')
      end

      it 'raises an error when message is empty' do
        args = { next_assignee: 'Mr_reviewer(reviewer)', message: '' }
        expect { subject.execute_and_generate_message(args) }.to raise_error(Ghostest::Error, 'message is required')
      end
    end
  end
end
