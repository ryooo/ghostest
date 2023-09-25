module Llm
  module Functions
    class AddToMemory < Base
      def function_name
        :add_to_memory
      end

      def initialize(message_container)
        @message_container = message_container
      end

      def definition
        return @definition unless @definition.nil?

        @definition = {
          name: self.function_name,
          description: I18n.t("functions.#{self.function_name}.description"),
          parameters: {
            type: :object,
            properties: {
              contents_to_memory: {
                type: :string,
                description: I18n.t("functions.#{self.function_name}.parameters.contents_to_memory"),
              },
            },
            required: [:contents_to_memory],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        if args[:contents_to_memory].nil? || args[:contents_to_memory].empty?
          raise "contents_to_memory is required"
        end
        @message_container.add_system_message(I18n.t("functions.#{self.function_name}.system_message_prefix", contents_to_memory: args[:contents_to_memory]))
        { result: 'success' }
      end
    end
  end
end
