require 'spec_helper'
require 'ghostest/config/agent'

RSpec.describe Ghostest::Config::Agent do
  let(:global_config) { double('GlobalConfig', use_web: true, language_klass: 'Ruby') }

  describe '#initialize' do
    let(:hash) { { role: 'test_programmer', system_prompt: 'System Prompt', color: 'blue' } }
    subject { described_class.new('Agent Name', hash, global_config) }

    it 'initializes correctly' do
      expect(subject.name).to eq 'Agent Name'
      expect(subject.role).to eq 'test_programmer'
      expect(subject.system_prompt).to eq 'System Prompt'
      expect(subject.color).to eq 'blue'
    end

    context 'when required keys are missing' do
      it 'raises ConfigError when role is missing' do
        hash.delete(:role)
        expect { described_class.new('Agent Name', hash, global_config) }.to raise_error(Ghostest::ConfigError, 'Agent role is required')
      end

      it 'raises ConfigError when system_prompt is missing' do
        hash.delete(:system_prompt)
        expect { described_class.new('Agent Name', hash, global_config) }.to raise_error(Ghostest::ConfigError, 'Agent system_prompt is required')
      end

      it 'raises ConfigError when color is missing' do
        hash.delete(:color)
        expect { described_class.new('Agent Name', hash, global_config) }.to raise_error(Ghostest::ConfigError, 'Agent color is required')
      end
    end
  end

  describe '#role_klass' do
    context 'when role is :test_programmer' do
      let(:hash) { { role: 'test_programmer', system_prompt: 'System Prompt', color: 'blue' } }
      subject { described_class.new('Agent Name', hash, global_config) }

      it 'returns Llm::Agents::Programmer' do
        expect(subject.role_klass).to eq Llm::Agents::TestProgrammer
      end
    end

    context 'when role is :reviewer' do
      let(:hash) { { role: 'reviewer', system_prompt: 'System Prompt', color: 'blue' } }
      subject { described_class.new('Agent Name', hash, global_config) }

      it 'returns Llm::Agents::Reviewer' do
        expect(subject.role_klass).to eq Llm::Agents::Reviewer
      end
    end

    context 'when role is :test_designer' do
      let(:hash) { { role: 'test_designer', system_prompt: 'System Prompt', color: 'blue' } }
      subject { described_class.new('Agent Name', hash, global_config) }

      it 'returns Llm::Agents::TestDesigner' do
        expect(subject.role_klass).to eq Llm::Agents::TestDesigner
      end
    end

    context 'when role is unknown' do
      let(:hash) { { role: 'unknown', system_prompt: 'System Prompt', color: 'blue' } }
      subject { described_class.new('Agent Name', hash, global_config) }

      it 'raises a ConfigError' do
        expect { subject.role_klass }.to raise_error(Ghostest::ConfigError, 'Unknown agent role unknown')
      end
    end
  end
end
