require 'spec_helper'

RSpec.describe Llm::Agents::TestDesigner do
      let(:config) { instance_double('Ghostest::Config', agents: { 'test_designer' => instance_double('Ghostest::Config::Agent', role: 'test_designer', system_prompt: 'System Prompt', color: 'blue') }) }
      let(:logger) { instance_double('Logger') }
      let(:test_designer) { described_class.new('test_designer', config, logger) }

  describe '#initialize' do
    it 'initializes the TestDesigner object with the given arguments' do
      expect(test_designer.name).to eq 'test_designer'
      expect(test_designer.config).to eq config
    end
  end
end