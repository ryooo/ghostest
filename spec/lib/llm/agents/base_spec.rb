require 'spec_helper'

RSpec.describe Llm::Agents::Base do
  let(:logger) { double('Logger') }
  let(:config) { Ghostest::Config.load(nil, {}) }
  let(:agent_config) { double('AgentConfig', role: 'test_programmer', color: :cyan) }

  before do
    allow(config).to receive(:agents).and_return({ 'Mr_programmer' => agent_config })
  end

  describe '#initialize' do
    subject { described_class.new('Mr_programmer', config, logger) }

    it 'sets the instance variables correctly' do
      expect(subject.instance_variable_get(:@name)).to eq 'Mr_programmer'
      expect(subject.instance_variable_get(:@config)).to eq config
      expect(subject.instance_variable_get(:@agent_config)).to eq agent_config
      expect(subject.instance_variable_get(:@logger)).to eq logger
    end
  end

  describe '#name_with_type' do
    subject { described_class.new('Mr_programmer', config, logger).name_with_type }

    it 'returns the correct string' do
      expect(subject).to eq 'Mr_programmer(test_programmer)'
    end
  end

  describe '#say' do
    let(:agent) { described_class.new('Mr_programmer', config, logger) }

    it 'logs the correct info message' do
      expect(logger).to receive(:info).with('Mr_programmer: Hello, world!'.colorize(:cyan))
      agent.say('Hello, world!')
    end
  end

  describe '#create_web_functions' do
    subject { described_class.new('Mr_programmer', config, logger).create_web_functions }

    it 'returns an array of GoogleSearch and OpenUrl instances' do
      expect(subject.map(&:class)).to contain_exactly(Llm::Functions::GoogleSearch, Llm::Functions::OpenUrl)
    end
  end
end
