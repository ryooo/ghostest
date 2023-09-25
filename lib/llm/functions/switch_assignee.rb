module Llm
  module Functions
    class SwitchAssignee < Base
      include AttrReader
      attr_reader :assignee, :messages

      def function_name
        :switch_assignee
      end

      def initialize(assignee, agents)
        @messages = []
        @assignee = assignee
        @agents = agents
        @valid_agents = agents.map(&:name_with_type)
      end

      def stop_llm_call?
        # stop always
        true
      end

      def last_message
        @messages.last[:message]
      end

      def last_assignee
        @messages.last[:name]
      end

      def definition
        # @assigneeに応じて毎回作り直す
        definition = {
          name: self.function_name,
          description: I18n.t("functions.#{self.function_name}.description"),
          parameters: {
            type: :object,
            properties: {
              next_assignee: {
                type: :string,
                description: I18n.t("functions.#{self.function_name}.parameters.next_assignee"),
                enum: @valid_agents - [@assignee.name_with_type],
              },
              message: {
                type: :string,
                description: I18n.t("functions.#{self.function_name}.parameters.message"),
              },
            },
            required: [:assignee, :message],
          },
        }
        definition
      end

      def execute_and_generate_message(args)
        if args[:next_assignee].nil? || args[:next_assignee].empty?
          raise Ghostest::Error.new("next_assignee is required")
        end
        if args[:message].nil? || args[:message].empty?
          raise Ghostest::Error.new("message is required")
        end
        next_assignee = @agents.find { |agent| agent.name_with_type == args[:next_assignee] }
        message = {
          name: @assignee.name_with_type,
          next_assignee: next_assignee.name_with_type,
          message: args[:message],
        }
        @assignee = next_assignee
        @messages << message
        message
      end
    end
  end
end
