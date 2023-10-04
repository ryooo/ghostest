module Llm
  module Functions
    class RecordLgtm < Base
      def function_name
        :record_lgtm
      end

      def initialize
        @lgtm = false
      end

      def stop_llm_call?
        # stop always
        true
      end

      def lgtm?
        !!@lgtm
      end

      def definition
        return @definition unless @definition.nil?

        @definition = {
          name: self.function_name,
          description: I18n.t("ghostest.functions.#{self.function_name}.description"),
          parameters: {
            type: :object,
            properties: {
              message: {
                type: :string,
                description: I18n.t("ghostest.functions.#{self.function_name}.parameters.message"),
              },
            },
            required: [:message],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        @lgtm = true

        { message: args[:message] }
      end
    end
  end
end
