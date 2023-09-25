require 'spec_helper'

RSpec.describe Ghostest::Manager do
  let(:config) { instance_double('Ghostest::Config', language_klass: double, agents: { 'agent1' => double(role_klass: double), 'agent2' => double(role_klass: double) }) }
  let(:test_condition) { instance_double('Ghostest::TestCondition') }
  let(:logger) { instance_double('Ghostest::Logger') }
  let(:switch_assignee_function) { instance_double('Llm::Functions::SwitchAssignee') }

  before do
    allow(Ghostest::TestCondition).to receive(:new).and_return(test_condition)
    allow(Ghostest::Logger).to receive(:instance).and_return(logger)
    allow(Llm::Functions::SwitchAssignee).to receive(:new).and_return(switch_assignee_function)
  end

  describe '#initialize' do
    subject { described_class.new(config) }

    it 'initializes @config, @should_work_paths, and @test_condition correctly' do
      expect(subject.instance_variable_get(:@config)).to eq(config)
      expect(subject.instance_variable_get(:@should_work_paths)).to eq([])
      expect(subject.instance_variable_get(:@test_condition)).to eq(test_condition)
    end
  end

  # The 'start_work!' method is not tested as per the implementation.
  # The 'wait_for_update' method will be tested next.
end
