module Ghostest
  class Config
    include AttrReader
    attr_reader :llm, :debug, :use_web, :max_token, :watch_files, :agents, :language

    def initialize(hash, options)
      @llm = options[:llm]
      @debug = options[:debug]
      @use_web = options[:use_web]

      @max_token = hash[:max_token] || 32000
      @language = (hash[:language] || raise(ConfigError.new("Language is required"))).to_sym
      @watch_files = hash[:watch_files] || raise(ConfigError.new("Watch files are required"))
      agents = hash[:agents] || []
      @agents = Hash[agents.map { |k, h| [k, Agent.new(k, h, self)] }].with_indifferent_access
      raise(ConfigError.new("2 Agents are required")) if @agents.size < 2
    end

    def llm_klass
      case @llm.to_sym
      when :azure_open_ai
        return Llm::Clients::AzureOpenAi
      else
        raise ConfigError.new("Unknown llm #{@llm}")
      end
    end

    def language_klass
      case self.language
      when :ruby
        return Ghostest::Languages::Ruby
      else
        raise ConfigError.new("Unknown language #{self.language}")
      end
    end

    def use_web?
      !!@use_web
    end

    class << self
      def load(config_path, options)
        options = options.with_indifferent_access
        default_config = parse_config_file(File.expand_path('config/ghostest.yml'))
        if config_path.nil?
          Config.new(default_config.with_indifferent_access, options)
        elsif File.exist?(config_path)
          Config.new(default_config.merge(parse_config_file(config_path)).with_indifferent_access, options)
        elsif (expanded = File.expand_path(config_path)) && File.exist?(expanded)
          Config.new(default_config.merge(parse_config_file(expanded)).with_indifferent_access, options)
        else
          raise ConfigError.new("Config file #{config_path} not found")
        end
      end

      private

      def parse_config_file(path)
        yaml = ERB.new(File.read(path)).result

        YAML.safe_load(
          yaml,
          permitted_classes: [Symbol],
          permitted_symbols: [],
          aliases: true
        )
      end
    end
  end
end
