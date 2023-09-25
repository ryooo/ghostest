require 'spec_helper'
require 'ghostest/config'
require 'llm/clients/azure_open_ai'
require 'ghostest/languages/ruby'

RSpec.describe Ghostest::Config do
  describe '#initialize' do
    context 'when called with valid parameters' do
      it 'correctly initializes the object' do
        options = { llm: :azure_open_ai, debug: true, use_web: true }
        hash = { max_token: 32000, language: :ruby, watch_files: %w[dir1 dir2], agents: { agent1: { role: :programmer, system_prompt: 'prompt', color: 'red' }, agent2: { role: :reviewer, system_prompt: 'prompt', color: 'blue' } } }
        config = described_class.new(hash, options)
        expect(config.llm).to eq :azure_open_ai
        expect(config.debug).to eq true
        expect(config.use_web).to eq true
        expect(config.max_token).to eq 32000
        expect(config.language).to eq :ruby
        expect(config.watch_files).to eq %w[dir1 dir2]
        expect(config.agents.keys).to eq %w[agent1 agent2]
      end
    end

    context 'when called without necessary parameters' do
      it 'raises an error' do
        options = { llm: :azure_open_ai, debug: true, use_web: true }
        hash = { max_token: 32000, watch_files: %w[dir1 dir2], agents: { agent1: { role: :programmer, system_prompt: 'prompt', color: 'red' }, agent2: { role: :reviewer, system_prompt: 'prompt', color: 'blue' } } }
        expect { described_class.new(hash, options) }.to raise_error(Ghostest::ConfigError)
      end
    end

    context 'when called without watch_files' do
      it 'raises an error' do
        options = { llm: :azure_open_ai, debug: true, use_web: true }
        hash = { max_token: 32000, language: :ruby, agents: { agent1: { role: :programmer, system_prompt: 'prompt', color: 'red' }, agent2: { role: :reviewer, system_prompt: 'prompt', color: 'blue' } } }
        expect { described_class.new(hash, options) }.to raise_error(Ghostest::ConfigError)
      end
    end

    context 'when called with less than 2 agents' do
      it 'raises an error' do
        options = { llm: :azure_open_ai, debug: true, use_web: true }
        hash = { max_token: 32000, language: :ruby, watch_files: %w[dir1 dir2], agents: { agent1: { role: :programmer, system_prompt: 'prompt', color: 'red' } } }
        expect { described_class.new(hash, options) }.to raise_error(Ghostest::ConfigError)
      end
    end

    context 'when max_token is not provided' do
      it 'assigns a default value' do
        options = { llm: :azure_open_ai, debug: true, use_web: true }
        hash = { language: :ruby, watch_files: %w[dir1 dir2], agents: { agent1: { role: :programmer, system_prompt: 'prompt', color: 'red' }, agent2: { role: :reviewer, system_prompt: 'prompt', color: 'blue' } } }
        config = described_class.new(hash, options)
        expect(config.max_token).to eq 32000
      end
    end

    context 'when agents are not provided' do
      it 'raises an error' do
        options = { llm: :azure_open_ai, debug: true, use_web: true }
        hash = { max_token: 32000, language: :ruby, watch_files: %w[dir1 dir2] }
        expect { described_class.new(hash, options) }.to raise_error(Ghostest::ConfigError)
      end
    end

    context 'when agents are provided' do
      it 'converts agents hash to have indifferent access' do
        options = { llm: :azure_open_ai, debug: true, use_web: true }
        hash = { max_token: 32000, language: :ruby, watch_files: %w[dir1 dir2], agents: { agent1: { role: :programmer, system_prompt: 'prompt', color: 'red' }, agent2: { role: :reviewer, system_prompt: 'prompt', color: 'blue' } } }
        config = described_class.new(hash, options)
        expect(config.agents).to be_a HashWithIndifferentAccess
      end
    end
  end

  describe '#llm_klass' do
    context 'when llm is :azure_open_ai' do
      it 'returns Llm::Clients::AzureOpenAi' do
        options = { llm: :azure_open_ai, debug: true, use_web: true }
        hash = { max_token: 32000, language: :ruby, watch_files: %w[dir1 dir2], agents: { agent1: { role: :programmer, system_prompt: 'prompt', color: 'red' }, agent2: { role: :reviewer, system_prompt: 'prompt', color: 'blue' } } }
        config = described_class.new(hash, options)
        expect(config.llm_klass).to eq Llm::Clients::AzureOpenAi
      end
    end

    context 'when llm is an unknown value' do
      it 'raises an error' do
        options = { llm: :unknown, debug: true, use_web: true }
        hash = { max_token: 32000, language: :ruby, watch_files: %w[dir1 dir2], agents: { agent1: { role: :programmer, system_prompt: 'prompt', color: 'red' }, agent2: { role: :reviewer, system_prompt: 'prompt', color: 'blue' } } }
        config = described_class.new(hash, options)
        expect { config.llm_klass }.to raise_error(Ghostest::ConfigError)
      end
    end
  end

  describe '#language_klass' do
    context 'when language is :ruby' do
      it 'returns Ghostest::Languages::Ruby' do
        options = { llm: :azure_open_ai, debug: true, use_web: true }
        hash = { max_token: 32000, language: :ruby, watch_files: %w[dir1 dir2], agents: { agent1: { role: :programmer, system_prompt: 'prompt', color: 'red' }, agent2: { role: :reviewer, system_prompt: 'prompt', color: 'blue' } } }
        config = described_class.new(hash, options)
        expect(config.language_klass).to eq Ghostest::Languages::Ruby
      end
    end

    context 'when language is an unknown value' do
      it 'raises an error' do
        options = { llm: :azure_open_ai, debug: true, use_web: true }
        hash = { max_token: 32000, language: :unknown, watch_files: %w[dir1 dir2], agents: { agent1: { role: :programmer, system_prompt: 'prompt', color: 'red' }, agent2: { role: :reviewer, system_prompt: 'prompt', color: 'blue' } } }
        config = described_class.new(hash, options)
        expect { config.language_klass }.to raise_error(Ghostest::ConfigError)
      end
    end
  end

  describe '#use_web?' do
    context 'when use_web is true' do
      it 'returns true' do
        options = { llm: :azure_open_ai, debug: true, use_web: true }
        hash = { max_token: 32000, language: :ruby, watch_files: %w[dir1 dir2], agents: { agent1: { role: :programmer, system_prompt: 'prompt', color: 'red' }, agent2: { role: :reviewer, system_prompt: 'prompt', color: 'blue' } } }
        config = described_class.new(hash, options)
        expect(config.use_web?).to eq true
      end
    end

    context 'when use_web is false' do
      it 'returns false' do
        options = { llm: :azure_open_ai, debug: true, use_web: false }
        hash = { max_token: 32000, language: :ruby, watch_files: %w[dir1 dir2], agents: { agent1: { role: :programmer, system_prompt: 'prompt', color: 'red' }, agent2: { role: :reviewer, system_prompt: 'prompt', color: 'blue' } } }
        config = described_class.new(hash, options)
        expect(config.use_web?).to eq false
      end
    end
  end

  describe '.load' do
    context 'when called with a valid config_path' do
      it 'correctly loads the configuration' do
        options = { llm: :azure_open_ai, debug: true, use_web: true }
        config_path = 'config/default.yml'
        config = described_class.load(config_path, options)
        expect(config).to be_a Ghostest::Config
      end
    end

    context 'when called with an invalid config_path' do
      it 'raises an error' do
        options = { llm: :azure_open_ai, debug: true, use_web: true }
        config_path = 'invalid/path.yml'
        expect { described_class.load(config_path, options) }.to raise_error(Ghostest::ConfigError)
      end
    end

    context 'when config_path is nil' do
      it 'loads the default configuration' do
        options = { llm: :azure_open_ai, debug: true, use_web: true }
        config = described_class.load(nil, options)
        expect(config).to be_a Ghostest::Config
      end
    end

    context 'when called with a valid config_path' do
      it 'merges the default config with the config from the provided path' do
        options = { llm: :azure_open_ai, debug: true, use_web: true }
        config_path = 'spec/dummy/ghostest_condition.yml'
        config = described_class.load(config_path, options)
        expect(config).to be_a Ghostest::Config
        expect(config.watch_files).to eq ['app/**/*.rb', 'lib/**/*.rb']
      end
    end

    context 'when config_path points to a file that is not a valid YAML file' do
      it 'raises an error' do
        options = { llm: :azure_open_ai, debug: true, use_web: true }
        config_path = 'spec/dummy/invalid.yml'
        expect { described_class.load(config_path, options) }.to raise_error(Ghostest::ConfigError)
      end
    end
  end
end
