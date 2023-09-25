module Llm
  module Agents
    class Base
      include AttrReader
      attr_reader :name, :config, :agent_config

      def initialize(name, config, logger)
        @name = name
        @config = config
        @agent_config = config.agents[name]
        @logger = logger
      end

      def name_with_type
        "#{self.name}(#{self.agent_config.role})"
      end

      def say(message, color: nil)
        if color.nil?
          @logger.info("#{self.name}: #{message}".send(self.agent_config.color))
        else
          if color
            @logger.info("#{self.name}: #{message}".send(color))
          else
            @logger.info("#{self.name}: #{message}")
          end
        end
      end

      def create_web_functions
        [
          Llm::Functions::GoogleSearch.new,
          Llm::Functions::OpenUrl.new,
        ]
      end
    end
  end
end
