require 'ghostest/attr_reader'
require 'ghostest/config'
module Ghostest
  class Config::Agent
    include AttrReader
    attr_reader :name, :occupation, :system_prompt, :color, :role

    def initialize(name, hash, global_config)
      @global_config = global_config
      @name = name
      @role = hash[:role] || raise(ConfigError.new("Agent role is required"))

      @system_prompt = hash[:system_prompt] || raise(ConfigError.new("Agent system_prompt is required"))
      @color = hash[:color] || raise(ConfigError.new("Agent color is required"))
    end

    def role_klass
      case @role.to_sym
      when :test_designer
        return Llm::Agents::TestDesigner
      when :test_programmer
        return Llm::Agents::TestProgrammer
      when :reviewer
        return Llm::Agents::Reviewer
      else
        raise ConfigError.new("Unknown agent role #{@role}")
      end
    end
  end
end
